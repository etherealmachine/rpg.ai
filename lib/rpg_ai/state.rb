module RpgAi
  class State
    include OpenAiFunctions

    attr_reader :inventory, :locations, :scenes, :current_location

    def initialize(json: nil)
      @inventory = json&.dig(:inventory) || {}
      @locations = json&.dig(:locations) || {
        'Archenbridge' => {
          description: 'A walled town on the river Archen. Most residents are occupied at or near the docks, processing the raw ore that comes down from the mines in the nearby mountains.',
          hooks: [
            'The last pilgrimage sent to the Monastery of the Glittering Caverns has been gone for over a month.',
          ],
          connected_locations: ['Temple of Dumathoin', 'Docks', 'Forest Road'],
        },
        'Temple of Dumathoin' => {
          description: 'A large temple dedicated to the dwarven god Dumathoin - god of mining and secrets under the mountain.',
          npcs: [{
            name: '<Head Priest>',
            description: 'The head priest of the Temple of Dumathoin in Archenbridge',
            disposition: '',
            secrets: [
              "The priest doesn't know it, but the letters can reveal the deteriorating state of the abbot's mind and increasing paranoia. The monastery hasn't been under attack by goblins - it's a psyker worm, up from the deep underdark that is infiltrating the abbot's mind.",
              'For the last few months, the priest has been receiving increasingly more strident letters from the abbot regarding goblin attacks on the monastery.',
              'Brother <Bookkeeper>, the bookkeeper, thinks someone has been skimming funds from the Glittering Caverns, selling healing crystals on the side.',
            ],
          }],
        },
        'Docks' => {
          description: 'Bustling docks with ore coming downriver from the mountain mines and equipment and goods coming upriver from the coast.',
          connected_locations: ['Falls of the Fish People'],
        },
        'Forest Road' => {
          description: 'Abandoned road leading into the mountains. Rumors say the elves of the forest delved too deep into dark magic and brought down their doom.',
          connected_locations: ['High Mountain Vale'],
        },
        'Falls of the Fish People' => {
          description: '',
          connected_locations: ['High Mountain Vale'],
        },
        'High Mountain Vale' => {
          description: '',
          connected_locations: ['Monastery of the Glittering Caverns', 'Goblin Cave'],
        },
        'Goblin Cave' => {
          description: '',
        },
        'Monastery of the Glittering Caverns' => {
          description: '',
        },
      }
      @current_location = json&.dig(:current_location) || 'Archenbridge'
      @scenes = json&.dig(:scenes) || []
    end

    def to_json
      {
        inventory:,
        locations:,
        current_location:,
        scenes:,
      }
    end

    def self.from_json(json)
      self.new(json: json&.with_indifferent_access)
    end

    def location
      @locations[@current_location]
    end

    def npcs
      @locations
    end

    def response_schema
      {
        type: :object,
        properties: {
          narration: {
            description: "The narration of the scene. Narration should include NPC's and dialog as necessary",
            type: :string,
          },
          items: {
            description: "Items that should be added or removed from the character's inventory",
            type: :array,
            items: {
              type: :object,
              properties: {
                item: {
                  description: 'Item name',
                  type: :string,
                },
                operation: {
                  description: 'Operation to perform on the item',
                  type: :string,
                  enum: ['add', 'remove'],
                },
                amount: {
                  description: 'Amount of items to add or remove',
                  type: :integer,
                },
              },
              required: ['item', 'operation', 'amount'],
              additionalProperties: false,
            },
          },
          npcs: {
            description: 'Any NPCs that are included in the narration',
            type: :array,
            items: {
              type: :object,
              properties: {
                name: {
                  description: 'The name of the NPC. Make up a proper name if necessary',
                  type: :string,
                },
                reference: {
                  description: 'The string previously used to refer to the NPC, e.g. <Male dwarf>.',
                  type: :string,
                },
                updated_description: {
                  description: "Description of the NPC. Can be left empty if the description hasn't changed.",
                  type: :string
                },
                interaction: {
                  description: "Summarize the player's interaction with the NPC (third-person past tense). Should be left empty if they player's haven't interacted with them.",
                  type: :string
                },
              },
              required: ['name', 'reference', 'updated_description', 'interaction'],
              additionalProperties: false,
            },
          },
        },
        required: ['narration', 'items', 'npcs'],
        additionalProperties: false,
      }
    end

    def handle_response(response)
      response[:items].each do |args|
        self.add_item(args) if args[:operation] == 'add'
        self.remove_item(args) if args[:operation] == 'remove'
      end
      response[:npcs].each do |args|
        self.update_npc(args)
      end
      response[:narration]
    end

    publish def meta(params)
      "Go ahead and answer the player's question based on your understanding of the adventure text."
    end, "The player is asking something meta about the game itself, or out-of-character", {
      question: {
        description: 'The question the player is asking.',
        type: :string,
      },
    }

    publish def illegal_response(params)
      "Go out-of-character and non-narrative, tell the player what they did wrong, and ask them to try again."
    end, "The player is assuming things that have not been established or attempting to describe the effects of an action, not just the action itself", {
      action: {
        description: 'The action the player has described.',
        type: :string,
      },
      effect: {
        description: 'The effect the player has described.',
        type: :string,
      },
      assumptions: {
        description: "Assumptions the player is making that haven't been established",
        type: :array,
        items: {
          type: :string,
        },
      },
    }

    publish def hack_and_slash(params)
      "The attack is successful, it damages the target appropriately for the type of attack."
    end, "Attacking a prepared enemy", {
      target: {
        description: 'The name of the target for the attack',
        type: :string,
      },
      attack_name: {
        description: "The name of the attack the player is using, if specified",
        type: :string,
      },
    }

    publish def defy_danger(params)
      "TODO"
    end, "Doing something in the face of impending peril", {}

    publish def parley(params)
      modifier = {
        'Non-Existent' => -2,
        'Trivial' => -1,
        'Valuable' => 0,
        'Critical' => 1,
      }[params[:leverage_rating]] + {
        'Trivial' => 2,
        'Minor' => 1,
        'Substantial' => 0,
        'Major' => -1,
        'Irreplaceable' => -2,
      }[params[:request_value]]
      if modifier == 0
        "The NPC can't quite agree but is close. Respond as the NPC and ask for either more leverage or less value."
      elsif modifier > 0
        "The NPC agrees to the request. Respond as the NPC."
      else
        "The NPC rejects the request. Respond as the NPC."
      end
    end, "The character is trying to get the NPC to do something for them or
    give something to them. In order for this to even be attempted, the 
    characters need Leverage. Leverage can be nasty or nice, the tone doesn't
    matter.  Leverage is anything that can convince the target of your parley
    to do something for you, and it can be physical or emotional.", {
      leverage: {
        description: 'The leverage the character claims to have over the NPC',
        type: :string,
      },
      leverage_rating: {
        description: "How good is the leverage the character's claim to have?",
        type: :string,
        enum: ['Non-Existent', 'Trivial', 'Valuable', 'Critical'],
      },
      leverage_reasoning: {
        description: "What is the reasoning behind the rating for the leverage?",
        type: :string,
      },
      request_category: {
        description: "What is the category of the character(s) request?",
        type: :string,
        enum: ['Nothing', 'Item', 'Action', 'Influence'],
      },
      request_value: {
        description: "How valuable is the thing being given to the NPC?",
        type: :string,
        enum: ['Trivial', 'Minor', 'Substantial', 'Major', 'Irreplaceable'],
      },
      value_reasoning: {
        description: "What is the reasoning behind the rating for the value?",
        type: :string,
      },
    }

    publish def interrogate_npc(params)
      unless params[:known]
        return "The NPC doesn't know the answer - as the NPC, explain this to the players."
      end
      if params[:hidden]
        return "The NPC knows but doesn't want to answer - as the NPC, make up a lie."
      end
      if params[:secret]
        return "As the NPC, say what you know about the secret."
      end
      "As the NPC, answer the question."
    end, "Asking a question the NPC could reasonably be able to answer.", {
      known: {
        description: 'Would the NPC reasonably know the anwswer?',
        type: :boolean,
      },
      hidden: {
        description: 'Would the NPC prefer to hide their anwswer?',
        type: :boolean,
      },
      secret: {
        description: "Does the question relate to one of the NPC's secrets?",
        type: :boolean,
      },
    }

    publish def interrogate_scene(params)
      "Answer the question."
    end, "Asking a clarifying question about the current location - the answer should not need to involve touching or physically manipulating anything.",
    {
      question: {
        description: 'The question being asked.',
        type: :string,
      },
    }

    publish def interact_with_scene(params)
      "Describe the object, if any secrets are related to the object, narratively reveal the secret."
    end, "Physical manipulation and touching of objects in the scene.", {
      object: {
        description: 'The name of the object.',
        type: :string,
      },
      action: {
        description: 'The action being taken with or on the object.',
        type: :string,
      },
    }

    publish def update_npc(params)
      location[:npcs] ||= []
      npc = location[:npcs].find do |npc|
        npc[:name] == params[:reference] || npc[:name] == params[:name]
      end
      if npc.present?
        npc[:name] = params[:name]
        npc[:reference] = params[:reference] unless params[:reference].empty?
        npc[:description] = params[:updated_description] unless params[:updated_description].empty?
        npc[:interactions] ||= []
        npc[:interactions] << params[:interaction] unless params[:interaction].empty?
        'Updated existing NPC'
      else
        location[:npcs] << {
          name: params[:name],
          reference: params[:reference],
          description: params[:updated_description],
          interactions: params[:interaction].empty? ? [] : [params[:interaction]],
          # TODO: so ugly
          profile_url: Session.first.generate_image(params[:updated_description]),
        }
        'Created a new NPC'
      end
    end, "Create or update an NPC (non-player character).", {
      name: {
        description: 'The name of the NPC.',
        type: :string,
      },
      reference: {
        description: 'The string previously used to refer to the NPC, e.g. <Male dwarf>.',
        type: :string,
      },
      updated_description: {
        description: "Updated description of the NPC. Should be left empty if the description hasn't changed.",
        type: :string,
      },
      interaction: {
        description: "Summarize the player's interaction with the NPC (third-person past tense). Should be left empty if they player's haven't interacted with them.",
        type: :string,
      }
    }

    publish def change_scene(params)
      if location[:connected_locations]&.include?(params[:new_location])
        scenes << {
          location: @current_location,
          summary: params[:summary],
        }
        @current_location = params[:new_location]
        "Location changed to #{@current_location}"
      elsif locations.include?(params[:new_location])
        "Location exists but is not connected to the current one. Go out-of-character and non-narrative, tell the player what their trying isn't possible and why, and to try something different."
      else
        "Location does not exist. If this location is part of the current location (a sub-location), continue with the scene. Otherwise, go out-of-character and non-narrative and ask the user to clarify and give them the list of locations connected to the current one."
      end
    end, "Move to a new location.", {
      new_location: {
        description: "The name of the new location. Must be one of the locations specified in the current location's description",
        type: :string,
      },
      summary: {
        description: 'Summary of events at the previous location.',
        type: :string,
      },
    }

    publish def add_item(params)
      @inventory[params[:item]] = { amount: 0 } if @inventory[params[:item]].nil?
      @inventory[params[:item]][:amount] += params[:amount]
      "#{params[:amount]} #{params[:item]} has been added to the inventory."
    end, "The characters have found or the NPC is giving the characters some items.", {
      item: {
        description: 'The name of the item(s).',
        type: :string,
      },
      amount: {
        description: 'The amount of the item(s) gained.',
        type: :number,
      },
    }

    publish def remove_item(params)
      @inventory[params[:item]] = { amount: 0 } if @inventory[params[:item]].nil?
      # TODO: Delete items at 0, handle negative inventory
      @inventory[params[:item]][:amount] -= params[:amount]
      "#{params[:amount]} #{params[:item]} have been removed from the inventory."
    end, "The characters gave away, used, or lost some items.", {
      item: {
        description: 'The name of the item(s).',
        type: :string,
      },
      amount: {
        description: 'The amount of the item(s) lost.',
        type: :number,
      },
    }
  end
end
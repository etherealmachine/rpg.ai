module RpgAi
  class State
    include OpenAiFunctions

    attr_reader :inventory

    def initialize
      @inventory = {}
    end

    publish def hack_and_slash(params)
        "The results of Hack and Slash was successful."
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
      end, "Doing something in the face of impending peril", {}

      publish def parley(params)
        "The NPC agrees to your request of #{params[:request_summary]}. Respond as the NPC."
      end, "The character is trying to get the NPC to do something for them or
      give something to them. In order for this to even be attempted, the 
      characters need Leverage. Leverage can be nasty or nice, the tone doesn't
      matter.  Leverage is anything that can convince the target of your parley
      to do something for you, and it can be physical or emotional.", {
        leverage: {
          description: 'The leverage the character claims to have over the NPC',
          type: :string,
          required: true,
        },
        leverage_rating: {
          description: "How good is the leverage the character's claim to have?",
          type: :string,
          enum: ['Non-Existent', 'Trivial', 'Valuable', 'Critical'],
          required: true,
        },
        leverage_reasoning: {
          description: "What is the reasoning behind the rating for the leverage?",
          type: :string,
          required: true,
        },
        request_category: {
          description: "What is the category of the character(s) request?",
          type: :string,
          enum: ['nothing', 'item', 'action', 'influence'],
          required: true,
        },
        request_summary: {
          description: "Summarize what the character(s) are asking for",
          type: :string,
          required: true,
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
          required: true,
        },
        hidden: {
          description: 'Would the NPC prefer to hide their anwswer?',
          type: :boolean,
          required: true,
        },
        secret: {
          description: "Does the question relate to one of the NPC's secrets?",
          type: :boolean,
          required: true,
        },
      }

      publish def interrogate_scene(params)
        "Answer the question."
      end, "Asking a clarifying question about the scene description - the answer
      should not need to involve touching or physically manipulating anything.",
      {}

      publish def interact_with_scene(params)
        "Describe the object, if any secrets are related to the object, narratively reveal the secret."
      end, "Physical manipulation and touching of objects in the scene.", {
        object: {
          description: 'The name of the object.',
          type: :string,
          required: true,
        },
        action: {
          description: 'The action being taken with or on the object.',
          type: :string,
          required: true,
        },
      }

      publish def change_scene(params)
        "Summarize what the players did in the current scene with particular attention to any changes that occurred."
      end, "Move to a new scene.", {
        scene: {
          description: 'The name of the scene.',
          type: :string,
          required: true,
        },
        summary: {
          description: 'Summary of changes to the existing scene.',
          type: :string,
          required: true,
        },
      }

      publish def add_item(params)
        @inventory[params[:item]] = { amount: 0 } if @inventory[params[:item]].nil?
        @inventory[params[:item]][:amount] += params[:amount]
        "#{params[:amount]} #{params[:item]} has been added to your inventory."
      end, "The characters have found or the NPC is giving the characters some items.", {
        item: {
          description: 'The name of the item(s).',
          type: :string,
          required: true,
        },
        amount: {
          description: 'The amount of the item(s) gained.',
          type: :number,
          required: true,
        },
      }

      publish def remove_item(params)
        @inventory[params[:item]] = { amount: 0 } if @inventory[params[:item]].nil?
        @inventory[params[:item]][:amount] -= params[:amount]
        "#{params[:amount]} #{params[:item]} have been removed from your inventory."
      end, "The characters gave away, used, or lost some items.", {
        item: {
          description: 'The name of the item(s).',
          type: :string,
          required: true,
        },
        amount: {
          description: 'The amount of the item(s) lost.',
          type: :number,
          required: true,
        },
      }
    end
end
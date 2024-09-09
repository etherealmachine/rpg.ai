module RpgAi
  class Objects
    
    def initialize
    end

    def objects
      {
        'Archenbridge' => {
          description: '',
          locations: ['Temple of Dumathoin', 'Docks', 'Forest Road'],
        },
        'Temple of Dumathoin' => {
          description: '',
          npcs: [{
            name: '<Make up a name for a male dwarf>',
            description: 'The head priest of the Temple of Dumathoin in Archenbridge',
            hooks: [
              'The last pilgrimage sent to the Monastery of the Glittering Caverns has been gone for over a month.',
            ],
            secrets: [
              "The priest doesn't know it, but the letters can reveal the deteriorating state of the abbot's mind and increasing paranoia. The monastery hasn't been under attack by goblins - it's a psyker worm, up from the deep underdark that is infiltrating the abbot's mind.",
              'For the last few months, the priest has been receiving increasingly more strident letters from the abbot regarding goblin attacks on the monastery.',
              'Brother <make up a name>, the bookkeeper, thinks someone has been skimming funds from the Glittering Caverns, selling healing crystals on the side.',
            ],
            interactions: [],
          }],
        },
        'Docks' => {
          description: '',
          npcs: [{}],
          locations: ['Falls of the Fish People'],
        },
        'Forest Road' => {
          description: '',
          locations: ['High Mountain Vale'],
        },
        'Falls of the Fish People' => {
          description: '',
          locations: ['High Mountain Vale'],
        },
        'High Mountain Value' => {
          description: '',
          locations: ['Monastery of the Glittering Caverns', 'Goblin Cave'],
        },
        'Goblin Cave' => {
          description: '',
        },
        'Monastery of the Glittering Caverns' => {
          description: '',
        },
      }
    end

    def current
      objects['Temple of Dumathoin'][:npcs].first
    end
  end
end

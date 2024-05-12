
use App::Asciio::Actions ;
use App::Asciio::Actions::Align ;
use App::Asciio::Actions::Arrow ;
use App::Asciio::Actions::Asciio ;
use App::Asciio::Actions::Box ;
use App::Asciio::Actions::Clipboard ;
use App::Asciio::Actions::Clone ;
use App::Asciio::Actions::Pen ;
use App::Asciio::Actions::Colors ;
use App::Asciio::Actions::Debug ;
use App::Asciio::Actions::Elements ;
use App::Asciio::Actions::ElementsManipulation ;
use App::Asciio::Actions::Eraser ;
use App::Asciio::Actions::File ;
use App::Asciio::Actions::Git ;
use App::Asciio::Actions::Mouse ;
use App::Asciio::Actions::Multiwirl ;
use App::Asciio::Actions::Presentation ;
use App::Asciio::Actions::Ruler ;
use App::Asciio::Actions::Selection ;
use App::Asciio::Actions::Shapes ;
use App::Asciio::Actions::Unsorted ;
use App::Asciio::Cross ;
use App::Asciio::Actions::ZBuffer ;

use App::Asciio::Scripting ;

#----------------------------------------------------------------------------------------------

register_action_handlers
(
'Undo'                               => [['C00-z', '000-u'],                       \&App::Asciio::Actions::Unsorted::undo                                              ],
'Redo'                               => [['C00-y', 'C00-r'],                       \&App::Asciio::Actions::Unsorted::redo                                              ],
'Zoom in'                            => [['000-plus', 'C0S-J', 'C00-scroll-up'],   \&App::Asciio::Actions::Unsorted::zoom, 1                                           ],
'Zoom out'                           => [['000-minus', 'C0S-H', 'C00-scroll-down'],\&App::Asciio::Actions::Unsorted::zoom, -1                                          ],
'mouse scroll switch tab forward'    => ['C0S-scroll-down',                        \&App::Asciio::GTK::Asciio::switch_tab, 1                                           ],
'mouse scroll switch tab backward'   => ['C0S-scroll-up',                          \&App::Asciio::GTK::Asciio::switch_tab, -1                                          ],


'Select next element'                => ['000-Tab',                                \&App::Asciio::Actions::ElementsManipulation::select_element_direction, [1, 0, 0]   ],
'Select previous element'            => ['00S-ISO_Left_Tab',                       \&App::Asciio::Actions::ElementsManipulation::select_element_direction, [0, 0, 0]   ],
'Select next non arrow'              => ['000-n',                                  \&App::Asciio::Actions::ElementsManipulation::select_element_direction, [1, 0, 1]   ],
'Select previous non arrow'          => ['00S-N',                                  \&App::Asciio::Actions::ElementsManipulation::select_element_direction, [0, 0, 1]   ],
'Select next arrow'                  => ['000-m',                                  \&App::Asciio::Actions::ElementsManipulation::select_element_direction, [1, 0, 2]   ],
'Select previous arrow'              => ['00S-M',                                  \&App::Asciio::Actions::ElementsManipulation::select_element_direction, [0, 0, 2]   ],

'Select all elements'                => [['C00-a', '00S-V'],                       \&App::Asciio::Actions::ElementsManipulation::select_all_elements                   ],
'Deselect all elements'              => ['000-Escape',                             \&App::Asciio::Actions::ElementsManipulation::deselect_all_elements                 ],
'Select connected elements'          => ['000-v',                                  \&App::Asciio::Actions::ElementsManipulation::select_connected                      ],
'Select elements by word'            => ['C00-f',                                  \&App::Asciio::Actions::ElementsManipulation::select_all_elements_by_words          ],
'Select elements by word no group'   => ['C0S-F',                                  \&App::Asciio::Actions::ElementsManipulation::select_all_elements_by_words_no_group ],

'Delete selected elements'           => [['000-Delete', '000-d'],                  \&App::Asciio::Actions::ElementsManipulation::delete_selected_elements              ],

'Edit selected element'              => [['000-2button-press-1','000-Return'],     \&App::Asciio::Actions::ElementsManipulation::edit_selected_element, 0              ],
'Edit selected element inline'       => [['C00-2button-press-1','0A0-Return'],     \&App::Asciio::Actions::ElementsManipulation::edit_selected_element, 1              ],

'Move selected elements left'        => ['000-Left',                               \&App::Asciio::Actions::ElementsManipulation::move_selection_left                   ],
'Move selected elements right'       => ['000-Right',                              \&App::Asciio::Actions::ElementsManipulation::move_selection_right                  ],
'Move selected elements up'          => ['000-Up',                                 \&App::Asciio::Actions::ElementsManipulation::move_selection_up                     ],
'Move selected elements down'        => ['000-Down',                               \&App::Asciio::Actions::ElementsManipulation::move_selection_down                   ],

'Move selected elements left quick'  => ['0A0-Left',                               \&App::Asciio::Actions::ElementsManipulation::move_selection_left, 10               ],
'Move selected elements right quick' => ['0A0-Right',                              \&App::Asciio::Actions::ElementsManipulation::move_selection_right, 10              ],
'Move selected elements up quick'    => ['0A0-Up',                                 \&App::Asciio::Actions::ElementsManipulation::move_selection_up, 10                 ],
'Move selected elements down quick'  => ['0A0-Down',                               \&App::Asciio::Actions::ElementsManipulation::move_selection_down, 10               ],

'Move selected elements left 2'      => ['000-h',                                  \&App::Asciio::Actions::ElementsManipulation::move_selection_left                   ],
'Move selected elements right 2'     => ['000-l',                                  \&App::Asciio::Actions::ElementsManipulation::move_selection_right                  ],
'Move selected elements up 2'        => ['000-k',                                  \&App::Asciio::Actions::ElementsManipulation::move_selection_up                     ],
'Move selected elements down 2'      => ['000-j',                                  \&App::Asciio::Actions::ElementsManipulation::move_selection_down                   ],

# mouse
'Mouse right-click'                  => ['000-button-press-3',                     \&App::Asciio::Actions::Mouse::mouse_right_click                                    ],

'Mouse left-click'                   => ['000-button-press-1',                     \&App::Asciio::Actions::Mouse::mouse_left_click                                     ],
'Start Drag and Drop'                => ['C00-button-press-1',                     sub { $_[0]->{ IN_DRAG_DROP} = 1 ; }                                                ],

'Mouse left-release'                 => ['000-button-release-1',                   \&App::Asciio::Actions::Mouse::mouse_left_release                                   ],
'Mouse left-release2'                => ['C00-button-release-1',                   \&App::Asciio::Actions::Mouse::mouse_left_release                                   ],
'Mouse left-release3'                => ['00S-button-release-1',                   \&App::Asciio::Actions::Mouse::mouse_left_release                                   ],
'Mouse left-release4'                => ['C0S-button-release-1',                   \&App::Asciio::Actions::Mouse::mouse_left_release                                   ],

# 'Mouse expand selection'             => ['',                     \&App::Asciio::Actions::Mouse::expand_selection                                     ],
'Mouse selection flip'               => ['00S-button-press-1',                     \&App::Asciio::Actions::Mouse::mouse_element_selection_flip                         ],

'Mouse quick link'                   => [['0A0-button-press-1', '000-period'],     \&App::Asciio::Actions::Mouse::quick_link                                           ],
'Mouse duplicate elements'           => [['0AS-button-press-1', '000-comma'],      \&App::Asciio::Actions::Mouse::mouse_duplicate_element                              ],
'Mouse quick box'                    => [['C0S-button-press-1'],                   \&App::Asciio::Actions::Elements::add_element, ['Asciio/box', 0]                    ],

'Arrow to mouse'                     => ['CA0-motion_notify',                      \&App::Asciio::Actions::Arrow::interactive_to_mouse                                 ], 
'Arrow mouse change direction'       => ['CA0-2button-press-1',                    \&App::Asciio::Actions::Arrow::change_arrow_direction                               ],      
'Arrow change direction'             => ['CA0-d',                                  \&App::Asciio::Actions::Arrow::interactive_change_arrow_direction                   ],      
'Wirl arrow add section'             => ['CA0-button-press-1',                     \&App::Asciio::Actions::Multiwirl::interactive_add_section, 0                       ],
'Wirl arrow add section no connect'  => ['CA0-button-press-3',                     \&App::Asciio::Actions::Multiwirl::interactive_add_section, 1                       ],
'Wirl arrow insert flex point'       => ['CA0-button-press-2',                     \&App::Asciio::Actions::Multiwirl::insert_wirl_arrow_section                        ],

'Mouse motion'                       => ['000-motion_notify',                      \&App::Asciio::Actions::Mouse::mouse_motion                                         ], 
'Mouse motion 2'                     => ['0AS-motion_notify',                      \&App::Asciio::Actions::Mouse::mouse_motion                                         ],
'Mouse drag canvas'                  => ['C00-motion_notify',                      \&App::Asciio::Actions::Mouse::mouse_drag_canvas                                    ],         

# mouse emulation
'Mouse emulation toggle'             => [['000-apostrophe', "'"],                  \&App::Asciio::Actions::Mouse::toggle_mouse                                         ],

'Mouse emulation left-click'         => [['000-odiaeresis', '000-space'],          \&App::Asciio::Actions::Mouse::mouse_left_click                                     ],
'Mouse emulation expand selection'   => ['00S-Odiaeresis',                         \&App::Asciio::Actions::Mouse::expand_selection                                     ],
'Mouse emulation selection flip'     => [['C00-odiaeresis', '000-1'],              \&App::Asciio::Actions::Mouse::mouse_element_selection_flip                         ],

'Mouse emulation right-click'        => ['000-adiaeresis',                         \&App::Asciio::Actions::Mouse::mouse_right_click                                    ],

'Mouse emulation move left'          => [['C00-Left', 'C00-h'],                    \&App::Asciio::Actions::Mouse::mouse_move, [-1,  0]                                 ],
'Mouse emulation move right'         => [['C00-Right', 'C00-l'],                   \&App::Asciio::Actions::Mouse::mouse_move, [ 1,  0]                                 ],
'Mouse emulation move up'            => [['C00-Up', 'C00-k'],                      \&App::Asciio::Actions::Mouse::mouse_move, [ 0, -1]                                 ],
'Mouse emulation move down'          => [['C00-Down', 'C00-j'],                    \&App::Asciio::Actions::Mouse::mouse_move, [ 0,  1]                                 ],

'Mouse emulation quick move left'    => ['0A0-h',                                  \&App::Asciio::Actions::Mouse::mouse_move, [-4,  0]                                 ],
'Mouse emulation quick move right'   => ['0A0-l',                                  \&App::Asciio::Actions::Mouse::mouse_move, [ 4,  0]                                 ],
'Mouse emulation quick move up'      => ['0A0-k',                                  \&App::Asciio::Actions::Mouse::mouse_move, [ 0, -4]                                 ],
'Mouse emulation quick move down'    => ['0A0-j',                                  \&App::Asciio::Actions::Mouse::mouse_move, [ 0,  4]                                 ],

'Mouse emulation drag left'          => ['00S-Left',                               \&App::Asciio::Actions::Mouse::mouse_drag_left                                      ],
'Mouse emulation drag right'         => ['00S-Right',                              \&App::Asciio::Actions::Mouse::mouse_drag_right                                     ],
'Mouse emulation drag up'            => ['00S-Up',                                 \&App::Asciio::Actions::Mouse::mouse_drag_up                                        ],
'Mouse emulation drag down'          => ['00S-Down',                               \&App::Asciio::Actions::Mouse::mouse_drag_down                                      ],

'Mouse on element id'                => ['not set',                                \&App::Asciio::Actions::Mouse::mouse_on_element_id                                  ],

'Copy to clipboard'                  => [['C00-c', 'C00-Insert'],                  \&App::Asciio::Actions::Clipboard::export_elements_to_system_clipboard              ],
'Insert from clipboard'              => [['C00-v', '00S-Insert'],                  \&App::Asciio::Actions::Clipboard::import_elements_from_system_clipboard            ],

'Save'                               => ['C00-s',                                  \&App::Asciio::Actions::File::save, undef                                           ],

'<< yank leader >>' =>
	{
	SHORTCUTS   => '000-y',
	
	'Copy to clipboard'                      => ['000-y', \&App::Asciio::Actions::Clipboard::export_elements_to_system_clipboard],
	'Export to clipboard & primary as ascii' => ['00S-Y', \&App::Asciio::Actions::Clipboard::export_to_clipboard_as_ascii       ],
	'Export to clipboard & primary as markup'=> ['000-m', \&App::Asciio::Actions::Clipboard::export_to_clipboard_as_markup      ],
	},

'<< paste leader >>' =>
	{
	SHORTCUTS   => '000-p',

	'Insert from clipboard'              => ['000-p', \&App::Asciio::Actions::Clipboard::import_elements_from_system_clipboard       ],
	'Import from primary to box'         => ['00S-P', \&App::Asciio::Actions::Clipboard::import_from_primary_to_box                  ],
	'Import from primary to text'        => ['0A0-p', \&App::Asciio::Actions::Clipboard::import_from_primary_to_text                 ],
	'Import from clipboard to box'       => ['000-b', \&App::Asciio::Actions::Clipboard::import_from_clipboard_to_box                ],
	'Import from clipboard to text'      => ['000-t', \&App::Asciio::Actions::Clipboard::import_from_clipboard_to_text               ],
	'Import from clipboard to image box' => ['000-i', \&App::Asciio::Actions::Clipboard::import_from_system_clipboard_to_image_box   ],
	},

'<< grouping leader >>' => 
	{
	SHORTCUTS   => '000-g',
	
	'Group selected elements'             => ['000-g', \&App::Asciio::Actions::ElementsManipulation::group_selected_elements                 ],
	'Ungroup selected elements'           => ['000-u', \&App::Asciio::Actions::ElementsManipulation::ungroup_selected_elements               ],
	'Move selected elements to the front' => ['000-f', \&App::Asciio::Actions::ElementsManipulation::move_selected_elements_to_front         ],
	'Move selected elements to the back'  => ['000-b', \&App::Asciio::Actions::ElementsManipulation::move_selected_elements_to_back          ],
	'Temporary move to the front'         => ['00S-F', \&App::Asciio::Actions::ElementsManipulation::temporary_move_selected_element_to_front],
	},

'<< stripes leader >>' => 
	{
	SHORTCUTS   => '0A0-g',
	
	'create stripes group'                => ['000-g', \&App::Asciio::Actions::ElementsManipulation::create_stripes_group, 0],
	'create one stripe group'             => ['000-1', \&App::Asciio::Actions::ElementsManipulation::create_stripes_group, 1],
	'ungroup stripes group'               => ['000-u', \&App::Asciio::Actions::ElementsManipulation::ungroup_stripes_group  ],
	},

'<< align leader >>' => 
	{
	SHORTCUTS   => '00S-A',
	
	'Align top'                           => ['000-t', \&App::Asciio::Actions::Align::align, 'top'       ],
	'Align left'                          => ['000-l', \&App::Asciio::Actions::Align::align, 'left'      ],
	'Align bottom'                        => ['000-b', \&App::Asciio::Actions::Align::align, 'bottom'    ],
	'Align right'                         => ['000-r', \&App::Asciio::Actions::Align::align, 'right'     ],
	'Align vertically'                    => ['000-v', \&App::Asciio::Actions::Align::align, 'vertical'  ],
	'Align horizontally'                  => ['000-h', \&App::Asciio::Actions::Align::align, 'horizontal'],
	},

'<< change color/font leader >>'=> 
	{
	SHORTCUTS   => '000-z',
	
	'Change font'                         => ['000-f', \&App::Asciio::Actions::Unsorted::change_font                           ],
	'<< Change color >>'                  => ['000-c', sub { $_[0]->use_action_group('group_color') ; }                        ] ,
	
	'Flip binding completion'             => ['000-b', sub { $_[0]->{USE_BINDINGS_COMPLETION} ^= 1 ; $_[0]->update_display() ;}],
	'Flip cross mode'                     => ['000-x', \&App::Asciio::Cross::flip_cross_mode                                   ],
	'Flip color scheme'                   => ['000-s', \&App::Asciio::Actions::Colors::flip_color_scheme                       ],
	'Flip transparent element background' => ['000-t', \&App::Asciio::Actions::Unsorted::transparent_elements                  ],
	'Flip grid display'                   => ['000-g', \&App::Asciio::Actions::Unsorted::flip_grid_display                     ],
	'Flip hint lines'                     => ['000-h', \&App::Asciio::Actions::Unsorted::flip_hint_lines                       ],
	'Flip edit inline'                    => ['000-i', \&App::Asciio::GTK::Asciio::switch_gtk_popup_box_type                   ], 
	'Flip show/hide connectors'           => ['000-v', \&App::Asciio::Actions::Unsorted::flip_connector_display                ],
	},

'group_color' => 
	{
	SHORTCUTS   => 'group_color',
	
	'Change elements foreground color'    => ['000-f', \&App::Asciio::Actions::Colors::change_elements_colors, 0       ],
	'Change elements background color'    => ['000-b', \&App::Asciio::Actions::Colors::change_elements_colors, 1       ],

	'Change Asciio background color'      => ['000-B', \&App::Asciio::Actions::Colors::change_background_color         ],
	'Change grid color'                   => ['000-g', \&App::Asciio::Actions::Colors::change_grid_color               ],
	},

'<< arrow leader >>' => 
	{
	SHORTCUTS   => '000-a',
	
	'Change arrow direction'              => ['000-d', \&App::Asciio::Actions::Arrow::change_arrow_direction                          ],
	'Flip arrow start and end'            => ['000-f', \&App::Asciio::Actions::Arrow::flip_arrow_ends                                 ],
	'Append multi_wirl section'           => ['000-s', \&App::Asciio::Actions::Multiwirl::append_section,                             ],
	'Insert multi_wirl section'           => ['00S-S', \&App::Asciio::Actions::Multiwirl::insert_wirl_arrow_section                   ],
	'Prepend multi_wirl section'          => ['C00-s', \&App::Asciio::Actions::Multiwirl::prepend_section                             ],
	'Remove last section from multi_wirl' => ['CA0-s', \&App::Asciio::Actions::Multiwirl::remove_last_section_from_section_wirl_arrow ],
	'Start no disconnect'                 => ['C00-d', \&App::Asciio::Actions::Multiwirl::disable_arrow_connector, 0                  ],
	'End no disconnect'                   => ['0A0-d', \&App::Asciio::Actions::Multiwirl::disable_arrow_connector, 1                  ],
	},

'<< debug leader >>' => 
	{
	SHORTCUTS   => '00S-D',
	
	'Display undo stack statistics'       => ['000-u', \&App::Asciio::Actions::Unsorted::display_undo_stack_statistics ],
	'Dump self'                           => ['000-s', \&App::Asciio::Actions::Debug::dump_self                        ],
	'Dump all elements'                   => ['000-e', \&App::Asciio::Actions::Debug::dump_all_elements                ],
	'Dump selected elements'              => ['000-E', \&App::Asciio::Actions::Debug::dump_selected_elements           ],
	'Display numbered objects'            => ['000-t', sub { $_[0]->{NUMBERED_OBJECTS} ^= 1 ; $_[0]->update_display() }],
	'Test'                                => ['000-o', \&App::Asciio::Actions::Debug::test                             ],
	'ZBuffer Test'                        => ['000-z', \&App::Asciio::Actions::ZBuffer::dump_crossings                 ],
	'Clear undo stack'                    => ['000-c', \&App::Asciio::Actions::Unsorted::clear_undo_stack              ],
	},

'<< tab leader >>' => 
	{
	SHORTCUTS   => '000-t',
	
	'add new tab'              => ['000-a',   \&App::Asciio::GTK::Asciio::add_tab                       ],
	'copy current tab'         => ['000-c',   \&App::Asciio::GTK::Asciio::copy_tab                      ],
	'delete current tab'       => ['000-d',   \&App::Asciio::GTK::Asciio::delete_tab                    ],
	'force delete current tab' => ['00S-D',   \&App::Asciio::GTK::Asciio::delete_tab, 1                 ],
	'show tabs lable'          => ['000-s',   \&App::Asciio::GTK::Asciio::show_all_tabs                 ],
	'hide tabs lable'          => ['000-h',   \&App::Asciio::GTK::Asciio::hide_all_tabs                 ],
	'switch tab forward'       => ['000-f',   \&App::Asciio::GTK::Asciio::switch_tab, 1                 ],
	'switch tab backward'      => ['000-b',   \&App::Asciio::GTK::Asciio::switch_tab, -1                ],
	'change tab lable name'    => ['000-n',   \&App::Asciio::GTK::Asciio::change_current_tab_lable_name ],
	},

'<< commands leader >>'=> 
	{
	SHORTCUTS   => '00S-colon',
	
	'Help'                                => ['000-h', \&App::Asciio::Actions::Unsorted::display_help                       ],
	'Add help box'                        => ['00S-H', \&App::Asciio::Actions::Elements::add_help_box,                                       ],
	
	'Display keyboard mapping'            => ['000-k', \&App::Asciio::Actions::Unsorted::display_keyboard_mapping_in_browser],
	'Display commands'                    => ['000-c', \&App::Asciio::Actions::Unsorted::display_commands                   ],
	'Display action files'                => ['000-f', \&App::Asciio::Actions::Unsorted::display_action_files               ],
	'Display manpage'                     => ['000-m', \&App::Asciio::Actions::Unsorted::manpage_in_browser                 ],
	
	'Run external script'                 => ['00S-exclam', \&App::Asciio::Scripting::run_external_script                   ],
	
	'Open'                                => ['000-e', \&App::Asciio::Actions::File::open                                   ],
	'Save'                                => ['000-w', \&App::Asciio::Actions::File::save, undef                            ],
	'SaveAs'                              => ['00S-W', \&App::Asciio::Actions::File::save, 'as'                             ],
	'Insert'                              => ['000-r', \&App::Asciio::Actions::File::insert                                 ],
	'Quit'                                => ['000-q', \&App::Asciio::Actions::File::quit                                   ],
	'Quit no save'                        => ['00S-Q', \&App::Asciio::Actions::File::quit_no_save                           ],
	},

'<< Insert leader >>' => 
	{
	SHORTCUTS   => '000-i',
	
	'Add connector'                       => ['000-c', \&App::Asciio::Actions::Elements::add_element, ['Asciio/connector', 0]                ],
	'Add text'                            => ['000-t', \&App::Asciio::Actions::Elements::add_element, ['Asciio/text', 1]                     ],
	'Add arrow'                           => ['000-a', \&App::Asciio::Actions::Elements::add_element, ['Asciio/wirl_arrow', 0]               ],
	# 'Add arrow'                           => ['000-a',
	# 						sub
	# 						{
	# 						App::Asciio::Actions::Elements::add_element($_[0], ['Asciio/wirl_arrow', 0]) ;
	# 						$_[0]->use_action_group('0A0-a') ;
	# 						}
	# 					] ,
	
	'Add angled arrow'                    => ['00S-A', \&App::Asciio::Actions::Elements::add_element, ['Asciio/angled arrow', 0]             ],
	
	'<< Stencil >>'                       => ['000-s', sub { $_[0]->use_action_group('group_insert_stencil') ; }                             ] ,
	'<< Multiple >>'                      => ['000-m', sub { $_[0]->use_action_group('group_insert_multiple') ; }                            ] ,
	'<< Unicode >>'                       => ['000-u', sub { $_[0]->use_action_group('group_insert_unicode') ; }                             ] ,
	'<< Box >>'                           => ['000-b', sub { $_[0]->use_action_group('group_insert_box') ; }                                 ] ,
	'<< Elements >>'                      => ['000-e', sub { $_[0]->use_action_group('group_insert_element') ; }                             ] ,
	'<< Ruler >>'                         => ['000-r', sub { $_[0]->use_action_group('group_insert_ruler') ; }                               ] ,
	'<< Line >>'                          => ['000-l', sub { $_[0]->use_action_group('group_insert_line') ; }                                ] ,
	'<< Connected >>'                     => ['000-k', sub { $_[0]->use_action_group('group_insert_connected') ; }                           ] ,
	},

'group_insert_stencil' => 
	{
	SHORTCUTS   => 'group_insert_stencil',
	
	'From user stencils'                  => ['000-s', \&App::Asciio::Actions::Elements::open_user_stencil                                   ], 
	'From default_stencil'                => ['000-d', \&App::Asciio::Actions::Elements::open_stencil, 'default_stencil.asciio'              ], 
	'From any stencil'                    => ['000-a', \&App::Asciio::Actions::Elements::open_stencil                                        ], 
	
	'From user elements'                  => ['000-0', \&App::Asciio::Actions::Elements::open_user_stencil, 'elements.asciio'                ], 
	'From user computer'                  => ['000-1', \&App::Asciio::Actions::Elements::open_user_stencil, 'computer.asciio'                ], 
	'From user people'                    => ['000-2', \&App::Asciio::Actions::Elements::open_user_stencil, 'people.asciio'                  ], 
	'From user buildings'                 => ['000-3', \&App::Asciio::Actions::Elements::open_user_stencil, 'buildings.asciio'               ], 
	},

'group_insert_multiple' => 
	{
	SHORTCUTS   => 'group_insert_multiple',
	
	'Add multiple texts'                  => ['000-t', \&App::Asciio::Actions::Elements::add_multiple_elements, 'Asciio/text'                ],
	'Add multiple boxes'                  => ['000-b', \&App::Asciio::Actions::Elements::add_multiple_elements, 'Asciio/box'                 ],
	},

'group_insert_ruler' => 
	{
	SHORTCUTS   => 'group_insert_ruler',
	
	'Add vertical ruler'                  => ['000-v', \&App::Asciio::Actions::Ruler::add_ruler, {TYPE => 'VERTICAL'}                        ],
	'Add horizontal ruler'                => ['000-h', \&App::Asciio::Actions::Ruler::add_ruler, {TYPE => 'HORIZONTAL'}                      ],
	'delete rulers'                       => ['000-d', \&App::Asciio::Actions::Ruler::remove_ruler                                           ],
	},

'group_insert_line' => 
	{
	SHORTCUTS   => 'group_insert_line',

	'Add ascii line'                      => ['000-l', \&App::Asciio::Actions::Elements::add_line, 0                                         ], 
	'Add ascii no-connect line'           => ['000-k', \&App::Asciio::Actions::Elements::add_non_connecting_line, 0                          ], 
	},

'group_insert_connected' => 
	{
	SHORTCUTS   => 'group_insert_connected',

	'Add connected box edit'              => ['000-b', \&App::Asciio::Actions::Elements::add_element_connected, ['Asciio/box', 1]             ], 
	'Add multiple connected box edit'     => ['00S-B', \&App::Asciio::Actions::Elements::add_multiple_element_connected, ['Asciio/box', 1]    ], 
	'Add connected text edit'             => ['000-t', \&App::Asciio::Actions::Elements::add_element_connected, ['Asciio/text', 1]            ], 
	'Add multiple connected text edit'     => ['00S-T', \&App::Asciio::Actions::Elements::add_multiple_element_connected, ['Asciio/text', 1]   ], 
	},

'group_insert_element' => 
	{
	SHORTCUTS   => 'group_insert_element',
	
	'Add connector type 2'                => ['000-c', \&App::Asciio::Actions::Elements::add_element, ['Asciio/connector2', 0]               ],
	'Add connector use top character'     => ['00S-C', \&App::Asciio::Actions::Elements::add_center_connector_use_top_character              ],
	'Add if'                              => ['000-i', \&App::Asciio::Actions::Elements::add_element, ['Asciio/Boxes/if', 1]                 ],
	'Add process'                         => ['000-p', \&App::Asciio::Actions::Elements::add_element, ['Asciio/Boxes/process', 1]            ],
	'Add rhombus'                         => ['0A0-r', \&App::Asciio::Actions::Elements::add_element, ['Asciio/Shape/rhombus', 0]            ],
	'Add ellipse'                         => ['000-e', \&App::Asciio::Actions::Elements::add_element, ['Asciio/Shape/ellipse', 0]            ],
	'Add triangle up'                     => ['000-t', \&App::Asciio::Actions::Elements::add_element, ['Asciio/Shape/triangle/up', 0]        ],
	'Add triangle down'                   => ['00S-T', \&App::Asciio::Actions::Elements::add_element, ['Asciio/Shape/triangle/down', 0]      ],
	},

'group_insert_box' => 
	{
	SHORTCUTS   => 'group_insert_box',
	
	'Add box'                             => ['000-b', \&App::Asciio::Actions::Elements::add_element, ['Asciio/box', 0]                      ],
	'Add shrink box'                      => ['000-s', \&App::Asciio::Actions::Elements::add_element, ['Asciio/shrink_box', 1]               ],
	
	'Add exec box'                        => ['C00-e', \&App::Asciio::Actions::Elements::add_element, ['Asciio/Boxes/exec', 1]               ],
	'Add exec box verbatim'               => ['C00-v', \&App::Asciio::Actions::Elements::add_element, ['Asciio/Boxes/exec verbatim', 1]      ],
	'Add exec box verbatim once'          => ['C00-o', \&App::Asciio::Actions::Elements::add_element, ['Asciio/Boxes/exec verbatim once', 1] ],
	'Add line numbered box'               => ['C00-l', \&App::Asciio::Actions::Elements::add_element, ['Asciio/Boxes/exec add lines', 1]     ],
	},

'group_insert_unicode' => 
	{
	SHORTCUTS   => 'group_insert_unicode',
	
	'Add unicode box'                       => ['000-b', \&App::Asciio::Actions::Elements::add_element, ['Asciio/box unicode', 0]              ],
	'Add unicode arrow'                     => ['000-a', \&App::Asciio::Actions::Elements::add_element, ['Asciio/wirl_arrow unicode', 0]       ],
	'Add unicode angled arrow'              => ['00S-A', \&App::Asciio::Actions::Elements::add_element, ['Asciio/angled arrow unicode', 0]     ],
	'Add unicode line'                      => ['000-l', \&App::Asciio::Actions::Elements::add_line, 1                                         ],
	
	'Add unicode bold line'                 => ['00S-L', \&App::Asciio::Actions::Elements::add_line, 2                                         ],
	'Add unicode double line'               => ['0A0-l', \&App::Asciio::Actions::Elements::add_line, 3                                         ],
	'Add unicode imaginary line'            => ['000-i', \&App::Asciio::Actions::Elements::add_line, 4                                         ],
	
	'Add unicode no-connect line'           => ['000-k', \&App::Asciio::Actions::Elements::add_non_connecting_line, 1                          ],
	'Add unicode no-connect bold line'      => ['00S-K', \&App::Asciio::Actions::Elements::add_non_connecting_line, 2                          ],
	'Add unicode no-connect double line'    => ['0A0-K', \&App::Asciio::Actions::Elements::add_non_connecting_line, 3                          ],
	'Add unicode no-connect imaginary line' => ['00S-I', \&App::Asciio::Actions::Elements::add_non_connecting_line, 4                          ],
	},

'<< element leader >>' => 
	{
	SHORTCUTS   => '000-e',
	
	'Shrink box'                     => ['000-s', \&App::Asciio::Actions::ElementsManipulation::shrink_box                              ],
	
	'Make element narrower'          => ['000-1',  \&App::Asciio::Actions::ElementsManipulation::resize_element_offset, [-1, 0]         ],
	'Make element taller'            => ['000-2',  \&App::Asciio::Actions::ElementsManipulation::resize_element_offset, [0,  1]         ],
	'Make element shorter'           => ['000-3',  \&App::Asciio::Actions::ElementsManipulation::resize_element_offset, [0, -1]         ],
	'Make element wider'             => ['000-4',  \&App::Asciio::Actions::ElementsManipulation::resize_element_offset, [1,  0]         ],
	
	'Make elements Unicode'          => ['C00-u',  \&App::Asciio::Actions::Asciio::make_selection_unicode, 1                            ],
	'Make elements not Unicode'      => ['C0S-U',  \&App::Asciio::Actions::Asciio::make_selection_unicode, 0                            ],
	'copy box element type'          => ['C00-t',  \&App::Asciio::Actions::Asciio::box_element_copy_type                                ],
	'copy arrow element type'        => ['C0S-T',  \&App::Asciio::Actions::Asciio::arrow_element_copy_type                              ],
	'paste element type'             => ['C00-p',  \&App::Asciio::Actions::Asciio::change_custom_element_type                           ],
   	'convert to big text'            => ['00S-T',  \&App::Asciio::Actions::Elements::convert_selected_element_to_text                   ], 
   	'convert to small pixels'        => ['000-p',  \&App::Asciio::Actions::Elements::convert_selected_elements_to_pixels                ], 
   	'freeze elements'                => ['000-f',  \&App::Asciio::Actions::Elements::freeze_elements                                    ], 
   	'unfreeze elements'              => ['00S-U',  \&App::Asciio::Actions::Elements::unfreeze_elements                                  ], 
   	'toggle disable freeze elements' => ['00S-D',  \&App::Asciio::Actions::ElementsManipulation::toggle_ignore_element_freeze           ], 
   	'image box increase gray scale'  => ['000-g',  \&App::Asciio::Actions::Box::image_box_change_gray_scale, 0.1                        ], 
   	'image box decrease gray scale'  => ['00S-G',  \&App::Asciio::Actions::Box::image_box_change_gray_scale, -0.1                       ], 
   	'image box increase alpha'       => ['000-h',  \&App::Asciio::Actions::Box::image_box_change_alpha, 0.1                             ], 
   	'image box decrease alpha'       => ['00S-H',  \&App::Asciio::Actions::Box::image_box_change_alpha, -0.1                            ], 
   	'image box revert to default'    => ['000-i',  \&App::Asciio::Actions::Box::image_box_revert_to_default_image                       ], 


	'<< BoxType>>'                   => ['000-b', sub { $_[0]->use_action_group('group_box_type_change') ; }                            ] ,
	'<< WirlArrowType>>'             => ['000-w', sub { $_[0]->use_action_group('group_wirl_arrow_type_change') ; }                     ] ,
	'<< AngledArrowType>>'           => ['000-a', sub { $_[0]->use_action_group('group_angled_arrow_type_change') ; }                   ] ,
	'<< EllipseType>>'               => ['000-e', sub { $_[0]->use_action_group('group_ellipse_type_change') ; }                        ] ,
	'<< RhombusType>>'               => ['000-r', sub { $_[0]->use_action_group('group_rhombus_type_change') ; }                        ] ,
	'<< TriangleUpType>>'            => ['000-u', sub { $_[0]->use_action_group('group_triangle_up_type_change') ; }                    ] ,
	'<< TriangleDownType>>'          => ['000-d', sub { $_[0]->use_action_group('group_triangle_down_type_change') ; }                  ] ,

	
	},

'group_box_type_change' => 
	{
	SHORTCUTS   => 'group_box_type_change',

	'change box type dash'                      => ['000-d', \&App::Asciio::Actions::Asciio::box_elements_change_type, 'dash'                           ],
	'change box type dot'                       => ['00S-D', \&App::Asciio::Actions::Asciio::box_elements_change_type, 'dot'                            ],
	'charge box type star'                      => ['000-s', \&App::Asciio::Actions::Asciio::box_elements_change_type, 'star'                           ],
	'charge box type math parantheses'          => ['000-m', \&App::Asciio::Actions::Asciio::box_elements_change_type, 'math_parantheses'               ],
	'charge box type unicode'                   => ['000-u', \&App::Asciio::Actions::Asciio::box_elements_change_type, 'unicode'                        ],
	'charge box type unicode imaginary'         => ['000-i', \&App::Asciio::Actions::Asciio::box_elements_change_type, 'unicode_imaginary'              ],
	'charge box type unicode bold'              => ['00S-U', \&App::Asciio::Actions::Asciio::box_elements_change_type, 'unicode_bold'                   ],
	'charge box type unicode bold imaginary'    => ['00S-I', \&App::Asciio::Actions::Asciio::box_elements_change_type, 'unicode_bold_imaginary'         ],
	'charge box type unicode double'            => ['000-l', \&App::Asciio::Actions::Asciio::box_elements_change_type, 'unicode_double'                 ],
	'charge box type unicode with filler type1' => ['000-1', \&App::Asciio::Actions::Asciio::box_elements_change_type, 'unicode_with_filler_type1'      ],
	'charge box type unicode with filler type2' => ['000-2', \&App::Asciio::Actions::Asciio::box_elements_change_type, 'unicode_with_filler_type2'      ],
	'charge box type unicode with filler type3' => ['000-3', \&App::Asciio::Actions::Asciio::box_elements_change_type, 'unicode_with_filler_type3'      ],
	'charge box type unicode with filler type4' => ['000-4', \&App::Asciio::Actions::Asciio::box_elements_change_type, 'unicode_with_filler_type4'      ],
	'charge box type unicode hollow dot'        => ['000-h', \&App::Asciio::Actions::Asciio::box_elements_change_type, 'unicode_hollow_dot'             ],
	'charge box type unicode math parantheses'  => ['00S-M', \&App::Asciio::Actions::Asciio::box_elements_change_type, 'unicode_math_paranthesesar'     ],
	},

'group_wirl_arrow_type_change' => 
	{
	SHORTCUTS   => 'group_wirl_arrow_type_change',

	'change wirl arrow type dash'                           => ['000-d', \&App::Asciio::Actions::Asciio::wirl_arrow_elements_change_type, 'dash'                   ],
	'change wirl arrow type dash line'                      => ['00S-D', \&App::Asciio::Actions::Asciio::wirl_arrow_elements_change_type, 'dash_line'              ],
	'change wirl arrow type dot'                            => ['C00-d', \&App::Asciio::Actions::Asciio::wirl_arrow_elements_change_type, 'dot'                    ],
	'change wirl arrow type dot_no_arrow'                   => ['0A0-d', \&App::Asciio::Actions::Asciio::wirl_arrow_elements_change_type, 'dot_no_arrow'           ],
	'change wirl arrow type star'                           => ['000-s', \&App::Asciio::Actions::Asciio::wirl_arrow_elements_change_type, 'star'                   ],
	'change wirl arrow type octo'                           => ['000-o', \&App::Asciio::Actions::Asciio::wirl_arrow_elements_change_type, 'octo'                   ],
	'change wirl arrow type unicode'                        => ['000-1', \&App::Asciio::Actions::Asciio::wirl_arrow_elements_change_type, 'unicode'                ],
	'change wirl arrow type unicode line'                   => ['000-u', \&App::Asciio::Actions::Asciio::wirl_arrow_elements_change_type, 'unicode_line'           ],
	'change wirl arrow type unicode bold'                   => ['000-2', \&App::Asciio::Actions::Asciio::wirl_arrow_elements_change_type, 'unicode_bold'           ],
	'change wirl arrow type unicode bold line'              => ['000-b', \&App::Asciio::Actions::Asciio::wirl_arrow_elements_change_type, 'unicode_bold_line'      ],
	'change wirl arrow type unicode_double'                 => ['000-3', \&App::Asciio::Actions::Asciio::wirl_arrow_elements_change_type, 'unicode_double'         ],
	'change wirl arrow type unicode double line'            => ['00S-B', \&App::Asciio::Actions::Asciio::wirl_arrow_elements_change_type, 'unicode_double_line'    ],
	'change wirl arrow type unicode unicode imaginary'      => ['000-4', \&App::Asciio::Actions::Asciio::wirl_arrow_elements_change_type, 'unicode_imaginary'      ],
	'change wirl arrow type unicode unicode imaginary line' => ['000-i', \&App::Asciio::Actions::Asciio::wirl_arrow_elements_change_type, 'unicode_imaginary_line' ],
	'change wirl arrow type unicode hollow dot'             => ['000-h', \&App::Asciio::Actions::Asciio::wirl_arrow_elements_change_type, 'unicode_hollow_dot'     ],
	},

'group_angled_arrow_type_change' => 
	{
	SHORTCUTS   => 'group_angled_arrow_type_change',

	'change angled arrow type dash'              => ['000-d', \&App::Asciio::Actions::Asciio::angled_arrow_elements_change_type, 'angled_arrow_dash'    ],
	'change angled arrow type unicode'           => ['000-u', \&App::Asciio::Actions::Asciio::angled_arrow_elements_change_type, 'angled_arrow_unicode' ],
	},

'group_ellipse_type_change' => 
	{
	SHORTCUTS   => 'group_ellipse_type_change',

	'change ellipse type normal'                 => ['000-n', \&App::Asciio::Actions::Asciio::ellipse_elements_change_type, 'ellipse_normal'                 ],
	'change ellipse type filler star'            => ['000-s', \&App::Asciio::Actions::Asciio::ellipse_elements_change_type, 'ellipse_normal_with_filler_star'],
	},

'group_rhombus_type_change' => 
	{
	SHORTCUTS   => 'group_rhombus_type_change',

	'change rhombus type normal'                 => ['000-n', \&App::Asciio::Actions::Asciio::rhombus_elements_change_type, 'rhombus_normal'                 ],
	'change rhombus type filler star'            => ['000-s', \&App::Asciio::Actions::Asciio::rhombus_elements_change_type, 'rhombus_normal_with_filler_star'],
	'change rhombus type sparseness'             => ['00S-S', \&App::Asciio::Actions::Asciio::rhombus_elements_change_type, 'rhombus_sparseness'             ],
	'change rhombus type unicode_slash'          => ['000-u', \&App::Asciio::Actions::Asciio::rhombus_elements_change_type, 'rhombus_unicode_slash'          ],
	},

'group_triangle_up_type_change' => 
	{
	SHORTCUTS   => 'group_triangle_up_type_change',

	'change triangle up type normal'             => ['000-n', \&App::Asciio::Actions::Asciio::triangle_up_elements_change_type, 'triangle_up_normal'         ],
	'change triangle up type dot'                => ['000-s', \&App::Asciio::Actions::Asciio::triangle_up_elements_change_type, 'triangle_up_dot'            ],
	},

'group_triangle_down_type_change' => 
	{
	SHORTCUTS   => 'group_triangle_down_type_change',

	'change triangle down type normal'          => ['000-n', \&App::Asciio::Actions::Asciio::triangle_down_elements_change_type,  'triangle_down_normal'     ],
	'change triangle down type dot'             => ['000-s', \&App::Asciio::Actions::Asciio::triangle_down_elements_change_type,  'triangle_down_dot'        ],
	},

'<< selection leader >>' =>
	{
	SHORTCUTS   => '000-s',
	ENTER_GROUP => \&App::Asciio::Actions::Selection::selection_enter,
	ESCAPE_KEYS => [ '000-s', '000-Escape' ],
	
	'Selection escape'               => [ '000-s',             \&App::Asciio::Actions::Selection::selection_escape                      ],
	'Selection escape2'              => [ '000-Escape',        \&App::Asciio::Actions::Selection::selection_escape                      ],

	'select flip mode'               => [ '000-e',             \&App::Asciio::Actions::Selection::selection_mode_flip                   ],
	'select motion'                  => [ '000-motion_notify', \&App::Asciio::Actions::Selection::select_motion_with_group              ],
	'select mouse click'             => [ '000-button-press-1',\&App::Asciio::Actions::Selection::select_elements, 0                    ],
	'select ignore group motion'     => [ 'C00-motion_notify', \&App::Asciio::Actions::Selection::select_motion_ignore_group            ],
	'select ignore group mouse click'=> [ 'C00-button-press-1',\&App::Asciio::Actions::Selection::select_elements, 1                    ],
	'<< polygon selection >>'        => [ '000-x',             sub { $_[0]->use_action_group('group_polygon') ; }                       ] ,
	},

'group_polygon' =>
	{
	SHORTCUTS => 'group_polygon',
	ENTER_GROUP => \&App::Asciio::GTK::Asciio::polygon_selection_enter,
	ESCAPE_KEYS => [ '000-x', '000-Escape' ],

	'Polygon selection escape'               => [ '000-x',               \&App::Asciio::GTK::Asciio::polygon_selection_escape             ],
	'Polygon selection escape2'              => [ '000-Escape',          \&App::Asciio::GTK::Asciio::polygon_selection_escape             ],
	'Polygon select motion'                  => [ '000-motion_notify',   \&App::Asciio::GTK::Asciio::polygon_selection_motion, 1          ],
	'Polygon deselect motion'                => [ 'C00-motion_notify',   \&App::Asciio::GTK::Asciio::polygon_selection_motion, 0          ],
	'Polygon select left-release'            => [ '000-button-release-1',\&App::Asciio::GTK::Asciio::polygon_selection_button_release     ],
	'Polygon select left-release 2'          => [ 'C00-button-release-1',\&App::Asciio::GTK::Asciio::polygon_selection_button_release     ],
	},

'<< eraser leader >>' =>
	{
	SHORTCUTS   => '00S-E',
	ENTER_GROUP => \&App::Asciio::Actions::Pen::eraser_enter,	
	ESCAPE_KEYS => '000-Escape',
	
	'Eraser escape'                  => [ '000-Escape',          \&App::Asciio::Actions::Pen::pen_escape, 1                               ],
	'Eraser motion'                  => [ '000-motion_notify',   \&App::Asciio::Actions::Pen::pen_mouse_motion                            ],
	'Eraser delete'                  => [ '000-button-press-1',  \&App::Asciio::Actions::Pen::pen_add_or_delete_element, 0                ],
	'Eraser delete2'                 => [ '000-Return',          \&App::Asciio::Actions::Pen::pen_add_or_delete_element, 0                ],
	},

'<< clone leader >>' =>
	{
	SHORTCUTS   => '000-c',
	ENTER_GROUP => \&App::Asciio::Actions::Clone::clone_enter,
	ESCAPE_KEYS => '000-Escape',
	
	'clone escape'                   => [ '000-Escape',          \&App::Asciio::Actions::Clone::clone_escape                                  ],
	'clone motion'                   => [ '000-motion_notify',   \&App::Asciio::Actions::Clone::clone_mouse_motion                            ], 
	
	'clone insert'                   => [ '000-button-press-1',  \&App::Asciio::Actions::Clone::clone_add_element                             ],
	'clone insert2'                  => [ '000-Return',          \&App::Asciio::Actions::Clone::clone_add_element                             ],
	'clone arrow'                    => [ '000-a',               \&App::Asciio::Actions::Clone::clone_set_overlay, ['Asciio/wirl_arrow', 0]   ],
	'clone angled arrow'             => [ '00S-A',               \&App::Asciio::Actions::Clone::clone_set_overlay, ['Asciio/angled_arrow', 0] ],
	'clone box'                      => [ '000-b',               \&App::Asciio::Actions::Clone::clone_set_overlay, ['Asciio/box', 0]          ],
	'clone text'                     => [ '000-t',               \&App::Asciio::Actions::Clone::clone_set_overlay, ['Asciio/text', 0]         ],
	'clone flip hint lines'          => [ '000-h',               \&App::Asciio::Actions::Unsorted::flip_hint_lines                            ],
	
	'clone left'                     => ['000-Left',             \&App::Asciio::Actions::ElementsManipulation::move_selection_left            ],
	'clone right'                    => ['000-Right',            \&App::Asciio::Actions::ElementsManipulation::move_selection_right           ],
	'clone up'                       => ['000-Up',               \&App::Asciio::Actions::ElementsManipulation::move_selection_up              ],
	'clone down'                     => ['000-Down',             \&App::Asciio::Actions::ElementsManipulation::move_selection_down            ],
	
	'clone emulation left'           => ['C00-Left',             \&App::Asciio::Actions::Mouse::mouse_move, [-1,  0]                          ],
	'clone emulation right'          => ['C00-Right',            \&App::Asciio::Actions::Mouse::mouse_move, [ 1,  0]                          ],
	'clone emulation up'             => ['C00-Up',               \&App::Asciio::Actions::Mouse::mouse_move, [ 0, -1]                          ],
	'clone emulation down'           => ['C00-Down',             \&App::Asciio::Actions::Mouse::mouse_move, [ 0,  1]                          ],
	},

'<< pen leader >>' =>
	{
	SHORTCUTS   => '000-b',
	ENTER_GROUP => \&App::Asciio::Actions::Pen::pen_mouse_emulation_enter,
	ESCAPE_KEYS => '000-Escape',
	
	'pen escape'                   => [ '000-Escape',          \&App::Asciio::Actions::Pen::pen_mouse_emulation_escape                  ],
	'pen motion'                   => [ '000-motion_notify',   \&App::Asciio::Actions::Pen::pen_mouse_motion                            ], 
	
	'pen insert or delete'         => [ '000-button-press-1',  \&App::Asciio::Actions::Pen::pen_add_or_delete_element, 0                ],
	'pen insert2 or delete2'       => [ '000-Return',          \&App::Asciio::Actions::Pen::pen_add_or_delete_element, 0                ],
	'pen mouse change char'        => [ '000-button-press-3',  \&App::Asciio::Actions::Pen::mouse_change_char                           ],
	'pen eraser switch'            => [ 'C0S-ISO_Left_Tab',    \&App::Asciio::Actions::Pen::pen_eraser_switch                           ],


	'mouse pen emulation toggle direction'        => [ 'C00-Tab',                          \&App::Asciio::Actions::Pen::toggle_mouse_emulation_move_direction                  ],

	'Mouse pen emulation move left'          => [['000-Left', 'C00-h'],                    \&App::Asciio::Actions::Pen::pen_mouse_emulation_move_left                          ],
	'Mouse pen emulation move right'         => [['000-Right', 'C00-l'],                   \&App::Asciio::Actions::Pen::pen_mouse_emulation_move_right                         ],
	'Mouse pen emulation move up'            => [['000-Up', 'C00-k'],                      \&App::Asciio::Actions::Pen::pen_mouse_emulation_move_up                            ],
	'Mouse pen emulation move down'          => [['000-Down', 'C00-j'],                    \&App::Asciio::Actions::Pen::pen_mouse_emulation_move_down                          ],
	'Mouse pen emulation move left quick'    => ['0A0-h',                                  \&App::Asciio::Actions::Pen::pen_mouse_emulation_move_left_quick                    ],
	'Mouse pen emulation move right quick'   => ['0A0-l',                                  \&App::Asciio::Actions::Pen::pen_mouse_emulation_move_right_quick                   ],
	'Mouse pen emulation move up quick'      => ['0A0-k',                                  \&App::Asciio::Actions::Pen::pen_mouse_emulation_move_up_quick                      ],
	'Mouse pen emulation move down quick'    => ['0A0-j',                                  \&App::Asciio::Actions::Pen::pen_mouse_emulation_move_down_quick                    ],
	'Mouse pen emulation move space'         => ['000-space',                              \&App::Asciio::Actions::Pen::pen_mouse_emulation_move_space                         ],
	'Mouse pen emulation move left tab'      => ['00S-ISO_Left_Tab',                       \&App::Asciio::Actions::Pen::pen_mouse_emulation_move_left_tab                      ],
	'Mouse pen emulation move right tab'     => ['000-Tab',                                \&App::Asciio::Actions::Pen::pen_mouse_emulation_move_right_tab                     ],
	'Mouse pen emulation enter'              => ['00S-Return',                             \&App::Asciio::Actions::Pen::mouse_emulation_press_enter_key                        ],
	'Mouse pen emulation delete pixel'       => ['000-Delete',                             \&App::Asciio::Actions::Pen::pen_delete_element, 1                                  ],
	'Mouse pen emulation back delete pixel'  => ['000-BackSpace',                          \&App::Asciio::Actions::Pen::pen_back_delete_element, 1                             ],
	'Mouse pen emulation switch next'        => ['C00-Return',                             \&App::Asciio::Actions::Pen::pen_switch_next_character_sets, 1                      ],
	'Mouse pen emulation change help '       => ['C0S-Return',                             \&App::Asciio::Actions::Pen::pen_switch_show_mapping_help_location,                 ],
	'Mouse pen emulation switch previous'    => ['0A0-Return',                             \&App::Asciio::Actions::Pen::pen_switch_previous_character_sets, 1                  ],


	(map { "pen insert " . $_->[0] => ["00S-" . $_->[0], \&App::Asciio::Actions::Pen::pen_enter_then_move_mouse, [$_->[1]]]}(
		['asterisk'    , '*']  ,
		['parenleft'   , '(']  ,
		['exclam'      , '!']  ,
		['at'          , '@']  ,
		['numbersign'  , '#']  ,
		['dollar'      , '$']  ,
		['percent'     , '%']  ,
		['asciicircum' , '^']  ,
		['ampersand'   , '&']  ,
		['parenright'  , ')']  ,
		['underscore'  , '_']  ,
		['plus'        , '+']  ,
		['braceleft'   , '{']  ,
		['braceright'  , '}']  ,
		['colon'       , ':']  ,
		['quotedbl'    , '"']  ,
		['asciitilde'  , '~']  ,
		['bar'         , '|']  ,
		['question'    , '?']  ,
		['less'        , '<']  ,
		['greater'     , '>']  , )) ,
	(map { "pen insert " . $_->[0] => ["000-" . $_->[0], \&App::Asciio::Actions::Pen::pen_enter_then_move_mouse, [$_->[1]]]}(
		['minus'        , '-']  ,
		['equal'        , '=']  ,
		['bracketleft'  , '[']  ,
		['bracketright' , ']']  ,
		['semicolon'    , ';']  ,
		['apostrophe'   , '\''] ,
		['grave'        , '`']  ,
		['backslash'    , '\\'] ,
		['slash'        , '/']  ,
		['comma'        , ',']  ,
		['period'       , '.']  , )) ,
	(map { "pen insert " . $_ => ["00S-" . $_, \&App::Asciio::Actions::Pen::pen_enter_then_move_mouse, [$_]] }('A'..'Z')),
	(map { "pen insert " . $_ => ["000-" . $_, \&App::Asciio::Actions::Pen::pen_enter_then_move_mouse, [$_]] }('a'..'z', '0'..'9')),
	},

'<< find leader >>' =>
	{
	SHORTCUTS   => '000-f',
	ENTER_GROUP => \&App::Asciio::GTK::Asciio::find_enter,
	ESCAPE_KEYS => ['000-Escape', '000-f'],
	
	'find escape'                  => [ '000-Escape',                            \&App::Asciio::GTK::Asciio::find_escape                  ],
	'find escape2'                 => [ '000-f',                                 \&App::Asciio::GTK::Asciio::find_escape                  ],
	'find next'                    => [ '000-n',                                 \&App::Asciio::GTK::Asciio::find_next                    ],
	'find previous'                => [ '00S-N',                                 \&App::Asciio::GTK::Asciio::find_previous                ],
	'find Zoom in'                 => [['000-plus', 'C0S-J', 'C00-scroll-up'],   \&App::Asciio::GTK::Asciio::find_zoom, 1                 ],
	'find Zoom out'                => [['000-minus', 'C0S-H', 'C00-scroll-down'],\&App::Asciio::GTK::Asciio::find_zoom, -1                ],
    'find Mouse drag canvas'       => [ 'C00-motion_notify',                     \&App::Asciio::Actions::Mouse::mouse_drag_canvas         ],         
	'find hunk search toggle'      => [ '000-Tab',                               \&App::Asciio::GTK::Asciio::hunk_search_toggle           ],
	'find flip repeat search mode' => [ '000-o',                                 \&App::Asciio::GTK::Asciio::find_flip_repeat_search_mode ],
	'clear all find highlight'     => [ '000-c',                                 \&App::Asciio::GTK::Asciio::find_enter, 1                ],
	},

'<< git leader >>' =>
	{
	SHORTCUTS   => '00S-G',
	ESCAPE_KEYS => '000-Escape',
	
	'Show git bindings'              => ['00S-question',                        sub { $_[0]->show_binding_completions(1) ; }                           ],
	
	'Quick git'                      => [['000-button-press-3', '000-c'],       \&App::Asciio::Actions::Git::quick_link                                ],
	
	'Git add box'                    => [ '000-b',                              \&App::Asciio::Actions::Elements::add_element, ['Asciio/box',  1]      ],
	'Git add text'                   => [ '000-t',                              \&App::Asciio::Actions::Elements::add_element, ['Asciio/text', 1]      ],
	'Git add arrow'                  => [ '000-a',                              \&App::Asciio::Actions::Elements::add_element, ['Asciio/wirl_arrow', 0]],
	'Git edit selected element'      => [['000-2button-press-1', '000-Return'], \&App::Asciio::Actions::Git::edit_selected_element                     ],
	
	'Git mouse left-click'           => [ '000-button-press-1',                 \&App::Asciio::Actions::Mouse::mouse_left_click                        ],
	'Git change arrow direction'     => [ '000-d',                              \&App::Asciio::Actions::Arrow::change_arrow_direction                  ],
	'Git undo'                       => [ '000-u',                              \&App::Asciio::Actions::Unsorted::undo                                 ],
	'Git delete elements'            => [['000-Delete', '000-x'],               \&App::Asciio::Actions::ElementsManipulation::delete_selected_elements ],
	
	'Git mouse motion'               => [ '000-motion_notify',                  \&App::Asciio::Actions::Mouse::mouse_motion                            ], 
	'Git move elements left'         => [ '000-Left',                           \&App::Asciio::Actions::ElementsManipulation::move_selection_left      ],
	'Git move elements right'        => [ '000-Right',                          \&App::Asciio::Actions::ElementsManipulation::move_selection_right     ],
	'Git move elements up'           => [ '000-Up',                             \&App::Asciio::Actions::ElementsManipulation::move_selection_up        ],
	'Git move elements down'         => [ '000-Down',                           \&App::Asciio::Actions::ElementsManipulation::move_selection_down      ],
	
	'Git mouse right-click'          => [ '0A0-button-press-3',                 \&App::Asciio::Actions::Mouse::mouse_right_click                       ],
	'Git flip hint lines'            => [ '000-h',                              \&App::Asciio::Actions::Unsorted::flip_hint_lines                      ],
	},

'<< slides leader >>' => 
	{
	SHORTCUTS   => '00S-S',
	ESCAPE_KEYS => '000-Escape',
	
	'Load slides'                    => ['000-l', \&App::Asciio::Actions::Presentation::load_slides          ] ,
	'previous slide'                 => ['00S-N', \&App::Asciio::Actions::Presentation::previous_slide       ],
	'next slide'                     => ['000-n', \&App::Asciio::Actions::Presentation::next_slide           ],
	'first slide'                    => ['000-g', \&App::Asciio::Actions::Presentation::first_slide          ],
	'show previous message'          => ['000-m', \&App::Asciio::Actions::Presentation::show_previous_message],
	'show next message'              => ['00S-M', \&App::Asciio::Actions::Presentation::show_next_message    ],
	'<< run script >>'               => ['000-s', sub { $_[0]->use_action_group('group_slides_script') ; }   ] ,
	},

'group_slides_script' => 
	{
	SHORTCUTS   => 'group_slides_script',
	ESCAPE_KEYS => '000-Escape',
	
	map { my $name =  "slides script $_" ; $name => ["000-$_", \&App::Asciio::Actions::Presentation::run_script, [$_] ] } ('a'..'z', '0'..'9'),
	},

'<< move arrow ends leader >>' =>
	{
	SHORTCUTS   => '0A0-a',
	ESCAPE_KEYS => '000-Escape',
	
	'arrow start up'                 => [ '000-Up',    \&App::Asciio::Actions::Arrow::move_arrow_start, [ 0, -1] ],
	'arrow start down'               => [ '000-Down',  \&App::Asciio::Actions::Arrow::move_arrow_start, [ 0,  1] ],
	'arrow start right'              => [ '000-Right', \&App::Asciio::Actions::Arrow::move_arrow_start, [ 1,  0] ],
	'arrow start left'               => [ '000-Left',  \&App::Asciio::Actions::Arrow::move_arrow_start, [-1,  0] ],
	'arrow start up2'                => [ '000-k',     \&App::Asciio::Actions::Arrow::move_arrow_start, [ 0, -1] ],
	'arrow start down2'              => [ '000-j',     \&App::Asciio::Actions::Arrow::move_arrow_start, [ 0,  1] ],
	'arrow start right2'             => [ '000-l',     \&App::Asciio::Actions::Arrow::move_arrow_start, [ 1,  0] ],
	'arrow start left2'              => [ '000-h',     \&App::Asciio::Actions::Arrow::move_arrow_start, [-1,  0] ],
	'arrow end up'                   => [ '00S-Up',    \&App::Asciio::Actions::Arrow::move_arrow_end,   [ 0, -1] ],
	'arrow end down'                 => [ '00S-Down',  \&App::Asciio::Actions::Arrow::move_arrow_end,   [ 0,  1] ],
	'arrow end right'                => [ '00S-Right', \&App::Asciio::Actions::Arrow::move_arrow_end,   [ 1,  0] ],
	'arrow end left'                 => [ '00S-Left',  \&App::Asciio::Actions::Arrow::move_arrow_end,   [-1,  0] ],
	'arrow end up2'                  => [ '00S-K',     \&App::Asciio::Actions::Arrow::move_arrow_end,   [ 0, -1] ],
	'arrow end down2'                => [ '00S-J',     \&App::Asciio::Actions::Arrow::move_arrow_end,   [ 0,  1] ],
	'arrow end right2'               => [ '00S-L',     \&App::Asciio::Actions::Arrow::move_arrow_end,   [ 1,  0] ],
	'arrow end left2'                => [ '00S-H',     \&App::Asciio::Actions::Arrow::move_arrow_end,   [-1,  0] ],
	},

'Asciio context_menu'                    => ['as_context_menu', undef, undef,          \&App::Asciio::Actions::Asciio::context_menu                                        ],
'Box context_menu'                       => ['bo_context_menu', undef, undef,          \&App::Asciio::Actions::Box::context_menu                                           ] ,
'Multi_wirl context_menu'                => ['mw_context_menu', undef, undef,          \&App::Asciio::Actions::Multiwirl::multi_wirl_context_menu                          ],
'Angled arrow context_menu'              => ['aa_ontext menu',  undef, undef,          \&App::Asciio::Actions::Multiwirl::angled_arrow_context_menu                        ],
'Ruler context_menu'                     => ['ru_context_menu', undef, undef,          \&App::Asciio::Actions::Ruler::context_menu                                         ],
'Shapes context_menu'                    => ['sh_context_menu', undef, undef,          \&App::Asciio::Actions::Shapes::context_menu                                        ],
) ;

register_first_level_group
(
SHORTCUTS => '00S-question',

'<< Insert leader >>'            => 1,
'<< yank leader >>'              => 1,
'<< selection leader >>'         => 1,
'<< paste leader >>'             => 1,
'<< grouping leader >>'          => 1,
'<< stripes leader >>'           => 1,
'<< align leader >>'             => 1,
'<< change color/font leader >>' => 1,
'<< arrow leader >>'             => 1,
'<< debug leader >>'             => 1,
'<< commands leader >>'          => 1,
'<< Insert leader >>'            => 1,
'<< slides leader >>'            => 1,
'<< element leader >>'           => 1,
'<< clone leader >>'             => 1,
'<< pen leader >>'               => 1,
'<< find leader >>'              => 1,
'<< git leader >>'               => 1,
'<< move arrow ends leader >>'   => 1,

'Select next non arrow'          => 1,
'Select previous non arrow'      => 1,
'Select next arrow'              => 1,
'Select previous arrow'          => 1,
'Select all elements'            => 1,
'Select connected elements'      => 1,

'Edit selected element inline'   => 1,

'Mouse quick link'               => 1,
'Mouse duplicate elements'       => 1,
'Mouse quick box'                => 1,

'Arrow to mouse'                 => 1,
'Arrow mouse change direction'   => 1,
'Arrow change direction'         => 1,
'Wirl arrow add section'         => 1,
'Wirl arrow insert flex point'   => 1,
) ;


# frozen_string_literal: true

require "json"

class Theme
  UnknownVariableName = Class.new(StandardError)
  MissingImage = Class.new(StandardError)

  ICON_NAMES = %i[
    icon_case
    icon_context
    icon_highlight
    icon_in_selection
    icon_preserve_case
    icon_regex
    icon_use_buffer
    icon_use_gitignore
    icon_whole_word
    icon_wrap
  ].freeze

  def initialize(&block)
    instance_eval(&block)
  end

  def context
    @context ||= {
      variables: {},
      rules: []
    }
  end

  def icon_names
    ICON_NAMES
  end

  def image(name)
    File.join("Slick/Themes/Default", name).tap do |path|
      unless File.file?("#{__dir__}/Themes/Default/#{name}")
        raise MissingImage, path
      end
    end
  end

  def save(path)
    File.open("#{__dir__}/#{path}", "w+") do |file|
      file << JSON.pretty_generate(context)
    end
  end

  def variable(name, value)
    context[:variables][name] = value
  end

  def rule(name, props)
    rule = props.each_with_object({}) do |(key, value), buffer|
      buffer[key.to_sym] = value
    end

    context[:rules] <<
      {class: name}.merge(rule.sort_by {|key, _value| key }.to_h)
  end

  def dasherize(input)
    input.to_s.tr("_", "-")
  end

  def method_missing(name, *args)
    return context[:variables][name] if context[:variables].key?(name)

    super
  end

  def respond_to_missing?(name, _include_all = false)
    context[:variables].key?(name) || super
  end
end

theme = Theme.new do
  variable :blackish, "#252525"
  variable :grayish, "#959ca9"
  variable :bluish, "#007acc"
  variable :light_gray, "#f5f5f5"
  variable :gray, "#999"
  variable :white, "#fff"

  variable :selected_color, "#3976ff"
  variable :sidebar_bg, "#e9e9e9"
  variable :sidebar_border_color, "#ddd"
  variable :sidebar_row_hover_bg, "#2e5fe111"
  variable :sidebar_row_bg, "#2e5fe1"
  variable :sidebar_row_fg, "#252525"
  variable :sidebar_title_fg, sidebar_row_fg
  variable :sidebar_row_selected_bg, "#3976ff"
  variable :sidebar_row_selected_fg, white
  variable :tab_bar_bg, "#f3f3f3"
  variable :tab_active_bg, white
  variable :tab_active_fg, blackish
  variable :tab_inactive_bg, "#e3e3e3"
  variable :tab_inactive_fg, grayish
  variable :tab_border_color, "#d9d9d9"
  variable :label_fg, white
  variable :label_hover_fg, white
  variable :tab_close_button_tint, "#7d7d7d"

  variable :panel_bg, white
  variable :panel_border, "#ddd"

  variable :status_button_hover_bg, "#ffffff22"
  variable :sidebar_button_color, white

  variable :status_fg, "#888"
  variable :status_bg, "#e6e7e9"
  variable :status_border, "#ddd"
  variable :status_button_hover_bg, "#ddd"
  variable :sidebar_button_color, "#888"

  variable :tooltip_bg, "#e9e9e9"
  variable :tooltip_fg, blackish

  variable :overlay_border_color, "#e9e9e9"
  variable :input_bg, "#eeeeef"
  variable :button_bg, "#006ef9"

  # Generic button group spacing
  rule :icon_button_group,
       spacing: 6

  icon_names.each do |rule_name|
    opacity = 0.3
    selected_opacity = 1

    rule rule_name,
         "layer0.opacity" => 0,
         "layer0.tint" => "",
         "layer0.texture": image("button-selected.png"),
         "layer1.texture" => image("#{dasherize(rule_name)}.png"),
         "layer1.opacity" => opacity,
         content_margin: [14, 11]

    rule rule_name,
         attributes: ["hover"],
         "layer1.opacity" => selected_opacity

    rule rule_name,
         parents: [
           {class: "icon_button_control", attributes: ["selected"]}
         ],
         "layer0.opacity" => 1,
         "layer0.tint" => "",
         "layer1.opacity": selected_opacity
  end

  # Sidebar ####################################################################
  rule :sidebar_container,
       "layer0.tint": sidebar_bg,
       "layer0.opacity": 1,
       "layer1.tint": sidebar_border_color,
       "layer1.opacity": 1,
       "layer1.inner_margin": [0, 0, 1, 0],
       "layer1.draw_center": false

  rule :sidebar_label, {
    attributes: ["selected"],
    parents: [{class: "tree_row", attributes: ["selected"]}],
    fg: sidebar_row_selected_fg
  }

  rule :tree_row, {
    attributes: ["hover"],
    "layer0.tint": sidebar_row_hover_bg,
    "layer0.opacity": 1
  }

  rule :tree_row, {
    attributes: ["!hover"],
    "layer0.opacity": 0.0
  }

  rule :tree_row, {
    attributes: %w[selected hover],
    "layer0.tint": sidebar_row_selected_bg
  }

  rule :tree_row, {
    attributes: ["selected"],
    "layer0.tint": sidebar_row_selected_bg,
    "layer0.opacity": 1
  }

  rule :sidebar_heading, {
    "font.size": 10,
    "font.bold": true,
    fg: sidebar_title_fg
  }

  rule :sidebar_tree, {
    row_padding: [0, 8],
    indent: 15,
    indent_offset: 10,
    indent_top_level: true
  }

  rule :sidebar_label, {
    parents: [{class: "tree_row"}],
    fg: sidebar_row_fg
  }

  rule :sidebar_label, {
    parents: [{class: "tree_row", attributes: ["selected"]}],
    fg: sidebar_row_selected_fg
  }

  # Status bar #################################################################
  rule :status_bar, {
    content_margin: [5, 0, 5, 0],
    # Layer 0: content
    "layer0.tint": status_bg,
    "layer0.opacity": 1.0,

    # Layer 1: border
    "layer1.tint": status_border,
    "layer1.opacity": 1.0,
    "layer1.inner_margin": [0, 1, 0, 0],
    "layer1.draw_center": false
  }

  rule :label_control, {
    parents: [{class: "status_bar"}],
    "font.size": 11,
    fg: status_fg
  }

  rule :status_button, {
    min_size: 0,
    content_margin: 5
  }

  rule :status_button, {
    attributes: ["hover"],
    "layer1.opacity": 1,
    "layer1.tint": status_button_hover_bg
  }

  rule :status_button, {
    attributes: ["!hover"],
    "layer1.opacity": 0
  }

  rule :sidebar_button_control, {
    "layer0.tint": sidebar_button_color,
    "layer0.opacity": 1
  }

  rule :sidebar_button_control, {
    settings: ["!show_sidebar_button"],
    "layer0.opacity": 0.0,
    content_margin: 0
  }

  rule :sidebar_button_control, {
    attributes: ["hover"],
    "layer1.tint": white,
    "layer1.opacity": 0.1
  }

  rule :disclosure_button_control, {
    "layer0.texture": image("disclosure-closed.png"),
    "layer0.opacity": 1,
    content_margin: [8, 8]
  }

  rule :disclosure_button_control, {
    attributes: ["expanded"],
    "layer0.texture": image("disclosure-expanded.png"),
    "layer0.opacity": 1,
    content_margin: [8, 8]
  }

  rule :icon_folder, {
    "layer0.texture": image("folder-closed.png"),
    "layer0.opacity": 1,
    content_margin: [9, 8]
  }

  rule :icon_folder, {
    parents: [{class: "tree_row", attributes: ["expanded"]}],
    "layer0.texture": image("folder-open.png"),
    "layer0.opacity": 1,
    content_margin: [9, 8]
  }

  # Code folding ###############################################################
  rule :fold_button_control, {
    "layer0.draw_center": false,
    "layer0.texture": image("folding-closed.png"),
    "layer0.opacity": 1,
    "layer0.inner_margin": [0, 0, 0, 0],
    content_margin: [8, 8]
  }

  rule :fold_button_control, {
    attributes: ["expanded"],
    "layer0.texture": image("folding-expanded.png")
  }

  # Tabs #######################################################################
  rule :tabset_control, {
    "layer0.tint": tab_bar_bg,

    "layer1.draw_center": false,
    "layer1.inner_margin": [0, 0, 0, 1],
    "layer1.tint": tab_border_color,
    "layer1.opacity": 1,

    content_margin: [0, 10, 8, 0],
    "layer0.opacity": 1,
    tint_index: 1,
    tab_overlap: 0,
    tab_width: 120,
    tab_height: 40,
    mouse_wheel_switch: false
  }

  rule :tab_control, {
    content_margin: [20, 10, 10, 10]
  }

  rule :tab_control, {
    "layer0.texture": "",
    "layer0.tint": blackish,
    "layer0.opacity": 1,

    "layer1.texture": "",
    "layer1.tint": tab_inactive_bg,
    "layer1.opacity": 1,

    "layer3.draw_center": false,
    "layer3.texture": "",
    "layer3.tint": tab_border_color,
    "layer3.opacity": 1,
    "layer3.inner_margin": [0, 1, 1, 0]
  }

  rule :tab_control, {
    attributes: ["selected"],
    "layer2.tint": tab_active_bg,
    "layer2.opacity": 1.0,
    "layer3.texture": image("tab-selected.png"),
    "layer3.tint": selected_color,
    "layer3.inner_margin": [0, 3, 0, 0]
  }

  rule :tab_control, {
    attributes: ["!selected"],
    "layer2.opacity": 0
  }

  rule :tab_label, {
    parents: [{class: "tab_control"}],
    fg: tab_inactive_fg
  }

  rule :tab_label, {
    parents: [{class: "tab_control", attributes: ["selected"]}],
    fg: tab_active_fg
  }

  rule :tab_close_button, {
    settings: ["show_tab_close_buttons"],
    content_margin: 7,
    "layer0.texture": image("tab-close.png"),
    "layer0.tint": tab_inactive_fg,
    "layer0.opacity": 0.00000001
  }

  rule :tab_close_button, {
    settings: ["show_tab_close_buttons"],
    parents: [{class: "tab_control", attributes: ["hover"]}],
    "layer0.texture": image("tab-close.png"),
    "layer0.tint": tab_inactive_fg,
    "layer0.opacity": 0.3
  }

  rule :tab_close_button, {
    settings: ["show_tab_close_buttons"],
    attributes: ["hover"],
    "layer0.texture": image("tab-close-hover.png"),
    "layer0.tint": tab_inactive_fg,
    "layer0.opacity": 0.3
  }

  rule :tab_close_button, {
    settings: ["show_tab_close_buttons"],
    parents: [{class: "tab_control", attributes: ["dirty"]}],
    "layer0.texture": image("tab-dirty.png"),
    "layer0.tint": tab_inactive_fg,
    "layer0.opacity": 0.3
  }

  rule :tab_close_button, {
    settings: ["show_tab_close_buttons"],
    parents: [{class: "tab_control", attributes: ["dirty"]}],
    attributes: ["hover"],
    "layer0.texture": image("tab-dirty-hover.png"),
    "layer0.tint": tab_inactive_fg
  }

  rule :tab_close_button, {
    parents: [{class: "tab_control", attributes: ["selected"]}],
    "layer0.tint": tab_close_button_tint,
    "layer0.opacity": 0.5
  }

  # Scrollbars #################################################################
  rule :scroll_bar_control, {
    parents: [{class: "popup_control auto_complete_popup"}],
    tint_modifier: [0, 0, 0, 0.05]
  }

  rule :scroll_area_control, {
    settings: ["overlay_scroll_bars"],
    overlay: true
  }

  rule :scroll_area_control, {
    settings: ["!overlay_scroll_bars"],
    overlay: false
  }

  rule :scroll_area_control, {
    parents: [{class: "sidebar_container"}],
    content_margin: [0, 10, 0, 10]
  }

  rule :scroll_bar_control, {
    "layer0.opacity": 1.0,
    content_margin: 4,
    tint_index: 0
  }

  rule :scroll_bar_control, {
    settings: ["overlay_scroll_bars"],
    "layer0.opacity": 0.0
  }

  rule :scroll_bar_control, {
    settings: ["!overlay_scroll_bars"],
    "layer0.opacity": 1.0
  }

  rule :scroll_track_control, {
    "layer0.texture": image("scroll_bar.png"),
    "layer0.opacity": 1.0,
    "layer0.inner_margin": 2,
    content_margin: [4, 4, 3, 4]
  }

  rule :puck_control, {
    "layer0.texture": image("scroll_puck.png"),
    "layer0.opacity": 1.0,
    "layer0.inner_margin": 2,
    content_margin: [0, 12]
  }

  rule :scroll_corner_control, {
    "layer0.opacity": 1.0,
    tint_index: 0
  }

  rule :scroll_track_control, {
    attributes: ["horizontal"],
    "layer0.texture": image("scroll_bar_horiz.png"),
    content_margin: [4, 4, 4, 3]
  }

  rule :puck_control, {
    attributes: ["horizontal"],
    "layer0.texture": image("scroll_puck_horiz.png"),
    content_margin: [12, 0]
  }

  rule :scroll_bar_control, {
    parents: [{class: "sidebar_container"}],
    "layer0.opacity": 0.0
  }

  rule :scroll_bar_control, {
    parents: [{class: "sidebar_container"}],
    attributes: ["horizontal"]
  }

  rule :scroll_track_control, {
    parents: [{class: "sidebar_container"}],
    "layer0.texture": image("sidebar_scroll_bar.png")
  }

  rule :puck_control, {
    parents: [{class: "sidebar_container"}],
    "layer0.texture": image("sidebar_scroll_puck.png")
  }

  rule :scroll_corner_control, {
    parents: [{class: "sidebar_container"}],
    "layer0.opacity": 0.0
  }

  rule :scroll_track_control, {
    parents: [{class: "sidebar_container"}],
    attributes: ["horizontal"],
    "layer0.texture": image("sidebar_scroll_bar_horiz.png")
  }

  rule :puck_control, {
    parents: [{class: "sidebar_container"}],
    attributes: ["horizontal"],
    "layer0.texture": image("sidebar_scroll_puck_horiz.png")
  }

  rule :scroll_bar_control, {
    parents: [{class: "switch_project_window"}],
    "layer0.tint": [235, 237, 239],
    tint_index: -1
  }

  rule :scroll_bar_control, {
    parents: [{class: "overlay_control"}],
    "layer0.opacity": 0.0,
    content_margin: [4, 0, 0, 0]
  }

  rule :scroll_track_control, {
    parents: [{class: "overlay_control"}],
    "layer0.texture": image("sidebar_scroll_bar.png")
  }

  rule :puck_control, {
    parents: [{class: "overlay_control"}],
    "layer0.texture": image("sidebar_scroll_puck.png")
  }

  # Tooltips ###################################################################
  rule :tool_tip_control, {
    "layer0.tint": tooltip_bg,
    "layer0.opacity": 1.0,
    content_margin: [10, 5, 10, 5]
  }

  rule :tool_tip_label_control, {
    "font.size": 12,
    fg: tooltip_fg
  }

  # Input ######################################################################
  rule :text_line_control, {
    content_margin: 4,
    "layer0.inner_margin": 2,
    "layer0.tint": input_bg,
    "layer0.opacity": 1.0,
    "layer1.draw_center": false,
    "layer1.texture": image("input--bw1--br2.png"),
    "layer1.tint": input_bg,
    "layer1.inner_margin": 6,
    "layer1.opacity": 1.0
  }

  rule :dropdown_button_control, {
    "layer0.texture": image("disclosure-expanded.png"),
    "layer0.opacity": 1,
    "layer3.opacity": 0,
    content_margin: 8
  }

  # Button #####################################################################
  rule :label_control, {
    parents: [{class: "button_control"}],
    "font.size": 13.0,
    fg: white
  }

  rule :button_control, {
    "layer0.tint": button_bg,
    "layer0.opacity": 1,
    "layer1.texture": "",
    "layer2.texture": "",
    "layer3.texture": "",
    content_margin: [10, 5],
    min_size: [80, 0]
  }

  # Autocomplete ###############################################################
  rule :auto_complete, {
    row_padding: 5,
    tint_index: 0,
    "layer0.opacity": 1.0,
    tint_modifier: white
  }

  rule :table_row, {
    parents: [{class: "auto_complete"}],
    attributes: ["selected"],
    "layer0.tint": light_gray,
    "layer0.opacity": 1,
    content_margin: [5]
  }

  rule :symbol_container, {
    content_margin: [5, 5, 5, 5]
  }

  rule :trigger_container, {
    # Autocomplete item's padding
    content_margin: [5, 5, 5, 5]
  }

  rule :auto_complete_details, {
    "font.size": 11.0,
    "font.italic": false
  }

  rule :auto_complete_description_label, {
    "font.size": 11.0,
    "font.italic": false
  }

  rule :auto_complete_description_label, {
    fg: blackish,
    "font.italic": false
  }

  rule :auto_complete_hint, {
    fg: grayish,
    "font.size": 13.0,
    "font.italic": false
  }

  rule :table_row, {
    parents: [{class: "auto_complete"}],
    attributes: ["!selected"],
    "layer0.opacity": 0
  }

  # Panels #####################################################################
  rule :panel_control, {
    content_margin: [0, 10, 5, 10],
    # Layer 0: content
    "layer0.tint": panel_bg,
    "layer0.opacity": 1.0,

    # Layer 1: border
    "layer1.tint": panel_border,
    "layer1.opacity": 1.0,
    "layer1.inner_margin": [0, 1, 0, 0],
    "layer1.draw_center": false
  }

  rule :panel_grid_control, {
    inside_spacing: 5,
    outside_hspacing: 5,
    outside_vspacing: 5
  }

  rule :text_output_control, {
    parents: [{class: "window"}],
    color_scheme_tint: white,
    content_margin: [10, 10, 10, 10]
  }

  # Quick Panel ################################################################
  %w[
    quick_panel_row
    mini_quick_panel_row
  ].each do |parent|
    # Quick Panel Row (Normal)
    rule parent, {
      "layer0.opacity": 1
    }

    rule :quick_panel_label, {
      parents: [{class: parent}],
      fg: gray,
      match_fg: selected_color,
      selected_fg: gray,
      selected_match_fg: gray
    }

    rule :quick_panel_path_label, {
      parents: [{class: parent}],
      fg: gray,
      match_fg: gray,
      selected_fg: gray,
      selected_match_fg: gray,
      "font.size": 11,
      "font.italic": false
    }

    # Quick panel link (e.g. package control's install)
    rule :quick_panel_detail_label, {
      parents: [{class: parent}],
      link_color: gray
    }

    # Quick panel link (Selected)
    rule :quick_panel_detail_label, {
      parents: [{class: parent, attributes: ["selected"]}],
      link_color: "white"
    }

    # Quick Panel Row (Unselected, Hover)
    rule parent, {
      attributes: ["!selected", "hover"],
      "layer0.tint": light_gray,
      "layer0.opacity": 1
    }

    # Quick Panel Row (Selected, Normal)
    rule parent, {
      attributes: ["selected", "!hover"],
      "layer0.tint": selected_color,
      "layer0.opacity": 1
    }

    rule :quick_panel_label, {
      parents: [
        {class: parent, attributes: ["selected", "!hover"]}
      ],
      fg: white,
      match_fg: white,
      selected_fg: white,
      selected_match_fg: white
    }

    rule :quick_panel_path_label, {
      parents: [{class: parent, attributes: ["selected"]}],
      fg: white,
      match_fg: white,
      selected_fg: white,
      selected_match_fg: white
    }

    # Quick Panel Row (Selected, Hover)
    rule parent, {
      attributes: %w[selected hover],
      "layer0.tint": selected_color,
      "layer0.opacity": 1
    }

    rule :quick_panel_label, {
      parents: [{class: parent, attributes: %w[selected hover]}],
      fg: white,
      match_fg: white,
      selected_fg: white,
      selected_match_fg: white
    }

    # Quick Panel Row (Undo Hover/Selected)
    rule parent, {
      attributes: ["!selected", "!hover"],
      "layer0.tint": white,
      "layer0.opacity": 1
    }

    rule :quick_panel_path_label, {
      parents: [{class: parent, attributes: ["!selected"]}],
      fg: gray,
      match_fg: gray,
      selected_fg: gray,
      selected_match_fg: gray
    }
  end

  # Quick panel box
  rule :overlay_control, {
    content_margin: [16, 16, 16, 31],
    # shadow
    "layer0.inner_margin": [24, 19, 24, 34],
    "layer0.texture": image("overlay_shadow--mt10.png"),
    "layer0.opacity": 1.0,
    # background
    "layer1.inner_margin": [20, 15, 20, 30],
    "layer1.texture": image("overlay--mt10--bw0--br0.png"),
    "layer1.tint": white,
    "layer1.opacity": 1.0,
    # border
    "layer2.inner_margin": [16, 11, 16, 26],
    "layer2.texture": image("overlay--mt10--bw0--br0.png"),
    "layer2.tint": overlay_border_color,
    "layer2.draw_center": false,
    "layer2.opacity": 1.0
  }

  rule :text_line_control, {
    parents: [{class: "overlay_control"}],
    color_scheme_tint: white,
    content_margin: 10,
    "layer0.tint" => white,
    "layer1.tint" => white
  }

  rule :quick_panel, {
    row_padding: [10, 10, 10, 10],
    "layer0.tint": white,
    "layer0.opacity": 1.0
  }

  rule :quick_panel_entry, {
    spacing: 10
  }

  rule :dialog, {
    "layer0.tint": light_gray,
    "layer0.opacity": 1.0
  }

  rule :title_label_control, {
    fg: blackish
  }

  rule :progress_bar_control, {
    "layer0.tint": bluish,
    "layer0.opacity": 1.0
  }
end

theme.save("Slick.sublime-theme")

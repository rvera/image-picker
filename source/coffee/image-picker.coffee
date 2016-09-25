#
# Image Picker source
# by Rodrigo Vera
#
jQuery.fn.extend({
  imagepicker: (opts = {}) ->
    this.each () ->
      select = jQuery(this)
      select.data("picker").destroy() if select.data("picker")
      select.data "picker", new ImagePicker(this, sanitized_options(opts))
      opts.initialized.call(select.data("picker")) if opts.initialized?
})

sanitized_options = (opts) ->
  default_options = {
    hide_select:      true,
    show_label:       false,
    initialized:      undefined,
    changed:          undefined,
    clicked:          undefined,
    selected:         undefined,
    limit:            undefined,
    limit_reached:    undefined,
  }
  jQuery.extend(default_options, opts)

both_array_are_equal = (a,b) ->
  return false if (!a || !b) || (a.length != b.length)
  a = a[..]
  b = b[..]
  a.sort()
  b.sort()
  for x, i in a
    return false if b[i] != x
  true

class ImagePicker
  constructor: (select_element, @opts={}) ->
    @select         = jQuery(select_element)
    @multiple       = @select.attr("multiple") == "multiple"
    @opts.limit     = parseInt(@select.data("limit")) if @select.data("limit")?
    @build_and_append_picker()

  destroy: ->
    for option in @picker_options
      option.destroy()
    @picker.remove()
    @select.off("change", @sync_picker_with_select)
    @select.removeData "picker"
    @select.show()

  build_and_append_picker: () ->
    @select.hide() if @opts.hide_select
    @select.on("change", @sync_picker_with_select)
    @picker.remove() if @picker?
    @create_picker()
    @select.after(@picker)
    @sync_picker_with_select()

  sync_picker_with_select: () =>
    for option in @picker_options
      if option.is_selected()
        option.mark_as_selected()
      else
        option.unmark_as_selected()

  create_picker: () ->
    @picker         =  jQuery("<ul class='thumbnails image_picker_selector'></ul>")
    @picker_options = []
    @recursively_parse_option_groups(@select, @picker)
    @picker

  recursively_parse_option_groups: (scoped_dom, target_container) ->
    for option_group in scoped_dom.children("optgroup")
      option_group = jQuery(option_group)
      container    = jQuery("<ul></ul>")
      container.append jQuery("<li class='group_title'>#{option_group.attr("label")}</li>")
      target_container.append jQuery("<li class='group'>").append(container)
      @recursively_parse_option_groups(option_group, container)
    for option in (new ImagePickerOption(option, this, @opts) for option in scoped_dom.children("option"))
      @picker_options.push option
      continue if !option.has_image()
      target_container.append option.node


  has_implicit_blanks: () ->
    (option for option in @picker_options when (option.is_blank() && !option.has_image())).length > 0

  selected_values: () ->
    if @multiple
      @select.val() || []
    else
      [@select.val()]

  toggle: (imagepicker_option, original_event) ->
    old_values = @selected_values()
    selected_value = imagepicker_option.value().toString()
    if @multiple
      if selected_value in @selected_values()
        new_values = @selected_values()
        new_values.splice( jQuery.inArray(selected_value, old_values), 1)
        @select.val []
        @select.val new_values
      else
        if @opts.limit? && @selected_values().length >= @opts.limit
          if @opts.limit_reached?
            @opts.limit_reached.call(@select)
        else
          @select.val @selected_values().concat selected_value
    else
      if @has_implicit_blanks() && imagepicker_option.is_selected()
        @select.val("")
      else
        @select.val(selected_value)
    unless both_array_are_equal(old_values, @selected_values())
      @select.change()
      @opts.changed.call(@select, old_values, @selected_values(), original_event) if @opts.changed?


class ImagePickerOption
  constructor: (option_element, @picker, @opts={}) ->
    @option = jQuery(option_element)
    @create_node()

  destroy: ->
    @node.find(".thumbnail").off("click", @clicked)

  has_image: () ->
    @option.data("img-src")?

  is_blank: () ->
    !(@value()? && @value() != "")

  is_selected: () ->
    select_value = @picker.select.val()
    if @picker.multiple
      jQuery.inArray(@value(), select_value) >= 0
    else
      @value() == select_value

  mark_as_selected: () ->
    @node.find(".thumbnail").addClass("selected")

  unmark_as_selected: () ->
    @node.find(".thumbnail").removeClass("selected")

  value: () ->
    @option.val()

  label: () ->
    if @option.data("img-label")
      @option.data("img-label")
    else
      @option.text()

  clicked: (event) =>
    @picker.toggle(this, event)
    @opts.clicked.call(@picker.select, this, event)  if @opts.clicked?
    @opts.selected.call(@picker.select, this, event) if @opts.selected? and @is_selected()

  create_node: () ->
    @node = jQuery("<li/>")
    image = jQuery("<img class='image_picker_image'/>")
    image.attr("src", @option.data("img-src"))
    thumbnail = jQuery("<div class='thumbnail'>")
    # Add custom class
    imgClass = @option.data("img-class")
    if imgClass
      @node.addClass(imgClass)
      image.addClass(imgClass)
      thumbnail.addClass(imgClass)
    # Add image alt
    imgAlt = @option.data("img-alt")
    if imgAlt
      image.attr('alt', imgAlt);
    thumbnail.on("click", @clicked)  
    thumbnail.append(image)
    thumbnail.append(jQuery("<p/>").html(@label())) if @opts.show_label
    @node.append( thumbnail )
    @node

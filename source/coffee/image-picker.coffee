#
# Image Picker source
# by Rodrigo Vera
#

jQuery.fn.extend({
  imagepicker: (options = {}) ->
    this.each () ->
      select = $(this)
      select.next("ul.image_picker_selector").remove()
      select.data "picker", new ImagePicker(this, sanitized_options(options))
})

sanitized_options = (opts) ->
  default_options = {
    mode:         "basic",
    hide_select:  true,
    show_label:   false,
  }
  jQuery.extend(default_options, opts)

class ImagePicker
  constructor: (select_element, @opts={}) ->
    @select         = $(select_element)
    @multiple       = @select.attr("multiple") == "multiple"
    @build_and_append_picker()

  has_implicit_blanks: ->
    (option for option in @picker_options when (option.is_blank() && !option.has_image())).length > 0

  build_and_append_picker: ->
    @select.hide() if @opts.hide_select
    @select.change {picker: this}, (event) ->
      event.data.picker.sync_picker_with_select()
    @picker.remove() if @picker?
    @create_picker()
    @select.after(@picker)
    @sync_picker_with_select()

  sync_picker_with_select: ->
    for option in @picker_options
      if option.is_selected()
        option.mark_as_selected()
      else
        option.unmark_as_selected()

  create_picker: ->
    @picker =  $("<ul class='thumbnails image_picker_selector'></div>")
    @picker_options = (new ImagePickerOption(option, this, @opts) for option in @select.find("option"))
    for option in @picker_options
      continue if !option.has_image()
      @picker.append( option.node )
    @picker

class ImagePickerOption
  constructor: (option_element, @picker, @opts={}) ->
    @option = $(option_element)
    @create_node()

  has_image: () ->
    @option.data("img-src")?

  is_blank: () ->
    !(@value()? && @value() != "")

  is_selected: () ->
    select_value = @picker.select.val()
    if @picker.multiple
      $.inArray(@value(), select_value) >= 0
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

  create_node: () ->
    @node = $("<li/>")
    image = $("<img class='image_picker_image'/>")
    image.attr("src", @option.data("img-src"))
    thumbnail = $("<div class='thumbnail'>")
    thumbnail.click {picker: @picker, option: this}, (event) ->
      picker  = event.data.picker
      option  = event.data.option
      if picker.multiple
        if $.inArray(option.value(), picker.select.val()) >= 0
          option.option.prop("selected", false)
        else
          option.option.prop("selected", true)
      else
        if picker.has_implicit_blanks() && option.is_selected()
          picker.select.val("")
        else
          picker.select.val(option.value())
      picker.sync_picker_with_select()
    thumbnail.append(image)
    thumbnail.append($("<p/>").html(@label())) if @opts.show_label
    @node.append( thumbnail )
    @node

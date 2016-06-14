$ ->
  newlsetterHiddenClass = 'newsletter__submit--hidden'
  $subscribeSubmit = $('#SignupSubmit').addClass(newlsetterHiddenClass)
  $subscribeEmail = $('#mce-EMAIL')
  $subscribeEmail.keyup (e)->
    email = $.trim($(e.target).val())

    console.log email
    if email == ''
      $subscribeSubmit.addClass(newlsetterHiddenClass)
    else
      $subscribeSubmit.removeClass(newlsetterHiddenClass)
      if email.match /[^@]+@[^@]+\.[^@]+/
        $subscribeSubmit.find('input').removeAttr('disabled')
      else
        $subscribeSubmit.find('input').attr('disabled', 'disabled')

  $cta = $('#Cta')

  $body = $('body')
  $header = $('.header')
  adjustShowingOfCta = () ->
    max = -4.5
    min = 0
    offset = ($body.height() - $header.height()) / 3
    scroll = window.pageYOffset
    if scroll <= 0
      margin = max
    else if scroll >= offset
      margin = min
    else
      margin = ((offset - scroll) / offset) * max
    $cta.css('right', "#{margin}em")

  scrolled = false

  $(window).scroll () ->
    scrolled = true

  setInterval(() ->
    if scrolled
      scrolled = false
      adjustShowingOfCta()
  , 150)

  ctaOpened = false
  $ctaOpener = $cta.find('#CtaOpener')
  $ctaOpener.click (e)->
    if $body.width() >= 800
      e.preventDefault()
      cls = 'quick-contact--opened'
      if ctaOpened
        $cta.removeClass cls
      else
        $cta.addClass cls
      ctaOpened = !ctaOpened
      old = $ctaOpener.text()
      $ctaOpener.text($ctaOpener.data('alt'))
      $ctaOpener.data('alt', old)

  $forms = $('#ContactForm, #Cta form')
  if $forms.length
    $('.error-message').hide()

    $forms.each (i, form) ->
      $form = $(form)
      $requiredFields = $form.find('input.required')
      $submit = $form.find('input[type=submit]')
      prefix = $form.data('prefix')
      if prefix
        prefix = "#{prefix}_"
      else
        prefix = ''

      requireField = ($input) ->
        $error = $input.siblings('.error-message')
        if $.trim($input.val()) == ''
          $input.addClass('error')
          $error.show()
          false
        else
          $input.removeClass('error')
          $error.hide()
          true

      $requiredFields.blur () ->
        requireField($(this))

      $form.submit (e) ->
        e.preventDefault()
        allValid = true
        $requiredFields.each () ->
          allValid = false unless requireField($(this))
          true

        return unless allValid

        $(this).find('.error-message').remove()

        normalSubmitText = $submit.attr('value')
        alternativeSubmitText = contactFormI18n.submit_alt
        $submit
          .attr('disabled', 'disabled')
          .val(alternativeSubmitText)

        $.post $form.attr('action') + '.json', $form.serialize(), (data) ->
          $submit.removeAttr('disabled').val(normalSubmitText)
          if data.errors
            $.each data.errors, (field, errs) ->
              $field = $form.find("input##{prefix}contact_form_#{field}")
              $.each errs, (i, err) ->
                $field.after($('<div class="error-message">').text(err).show())
            $submit
              .removeAttr('disabled')
              .val(normalSubmitText)
          else
            $form.after('<div class="notice">' + contactFormI18n.submitted + '</div>')
            $form.find('input, select').attr('disabled', 'disabled')
            setTimeout(->
              remove = $form.data('remove')
              if remove
                $form.parents("##{remove}").remove()
              else
                $form.remove()
            , 3000)

    $ContactForm = $('#ContactForm')
    if $ContactForm.length
      if $ContactForm.find('.alternatives input:checked').length == 0
        if window.location.hash != ''
          toCheck = $ContactForm.
            find(".alternatives input[value=#{window.location.hash.split('#')[1]}]")
        else
          toCheck = $ContactForm.find('.alternatives input:first')
        toCheck.attr('checked', 'checked')

    $contactFormName = $('#contact_form_name')
    $contactFormName.change ()->
      if $.trim($(this).val()) != ''
        $ContactForm.find('.contact__extra').addClass('contact__extra--shown')
        $contactFormName.unbind('change')


  $('.swipebox').swipebox();


  $slider = $('.slider')
  $slider.slick
    'accesibility': true,
    'arrows': false,
    'autoplay': true,
    'autoplaySpeed': 5000,
    'dots': true,
    'draggable': false,
    'fade': true,
  $slider.find('.slider__slide').show()

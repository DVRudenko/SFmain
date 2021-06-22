$(document).ready(function () {
    var mySwiper;
    var swiperNavMenu;
    var isScroll = false;

    function Comments(el) {
        this.comments      = $(el).find('.comment-block');
        this.openPopupBtn  = $(el).find('.button-chat');
        this.closePopupBtn = this.comments.find('.button-popup-close');
        this.openPopupBtn.on('click', this.openPopup.bind(this));
        this.closePopupBtn.on('click', this.closePopup.bind(this));
    }

    Comments.prototype.openPopup = function() {
        this.comments.addClass('open');
        this.comments.find('textarea.selected').focus();
    };

    Comments.prototype.closePopup = function() {
        this.comments.removeClass('open');
    };

    function DropDownNavigation(el) {
        this.enableScroll = true;
        this.nav   = $(el);
        this.openBlock = this.nav.find('.active-block');
        this.links = this.nav.find('.sub-menu-item');
        this.activeLink = this.nav.find('.active-item');
        this.links.on('click', this.toggleSlide.bind(this));
        this.openBlock.on('click', this.openPopup.bind(this));
        $(window).on('scroll', this.scrollContent.bind(this));
    }

    DropDownNavigation.prototype.scrollContent = function() {
        /*if ($(window).width() <= 1020) {
            var that = this;
            var scrollPos = $(window).scrollTop();
            $('.swiper-container-parent > .swiper-wrapper > .swiper-slide').each(function() {

                var current = $(this);

                if (current.position().top <= scrollPos && current.position().top + current.height() > scrollPos + 40 ) {
                    var el = that.links.filter('[data-hash="' + current.data('hash') + '"]');
                    if (that.enableScroll) {
                        that.toggleActiveLink(el);
                    }
                }
            });
        }*/
    };

    DropDownNavigation.prototype.toggleSlide = function(event) {
        event.preventDefault();
        var that = this;
        var slide = $(event.target).closest('.sub-menu-item');
        if (!slide.length) {
            return;
        }
        var slideData = slide.data('hash');
        var index;
        /*if ($(window).width() <= 1020) {
            index = $('.swiper-container-parent .swiper-slide[data-hash='+ slideData +']');
            that.enableScroll = false;
            $('html, body').animate({
                scrollTop: (index.offset().top - 70)
            },500, function () {
                that.enableScroll = true;
            });
            this.toggleActiveLink(slide);

        } else {

        }*/
        index = $('.swiper-container-parent .swiper-slide[data-hash='+ slideData +']').index();
        $('.swiper-container-navigation .swiper-slide').removeClass('active-nav');
        swiperNavMenu.slideTo( index, 0, false);
        mySwiper.slideTo( index, 500, false);
        this.toggleActiveLink(slide);
    };

    DropDownNavigation.prototype.toggleActiveLink  = function(el) {
        if (!el.length) {
            return;
        }
        this.links.removeClass('active');
        el.addClass('active');
        this.activeLink.find('.active-item-text').text(el.eq(0).text());
    };

    DropDownNavigation.prototype.openPopup = function(event) {
        event.preventDefault();
        $(event.target).closest('.active-block').toggleClass('open');
    };

    function DropUpNavigation(el) {
        this.nav       = $(el);
        this.openBlock = this.nav.find('.dropbtn');
        this.content   = this.nav.find('.dropup-content');

        this.openBlock.on('click', this.openPopup.bind(this));
    }

    DropUpNavigation.prototype.openPopup = function(event) {
        event.preventDefault();
        this.nav.toggleClass('open');
    };

    DropUpNavigation.prototype.getCurrentMenu = function() {
        var index = mySwiper.activeIndex;
        var data  = $(mySwiper.slides[index]).data('dropmenu');
        if (data) {
            this.createMenu(data);
            this.nav.show();
        } else {
            this.close();
            this.nav.hide();
        }
    }

    DropUpNavigation.prototype.createMenu = function(menu) {
        var map = Object.entries(menu).map(function ([key, value]) {
            return {key, value};
        });
        var new_menu = '';
        $(map).each(function(index,value) {
            new_menu += '<a href="'+ value['value'] +'">'+ value['key'] +'</a>';
        });
        this.content.html(new_menu);
    }

    DropUpNavigation.prototype.close = function() {
        this.nav.removeClass('open');
    }

    function SliderNavigation(el) {
        this.popups     = $(el);
        this.openPupupBtn  = $('.button-menu');
        this.openPupupFormBtn  = $('.button-user');
        this.openPupupBtn.on('click', this.openPopup.bind(this));
        this.openPupupFormBtn.on('click', this.openPopup.bind(this));
        $(window).on('click', this.closePopup.bind(this))
    }

    SliderNavigation.prototype.openPopup = function(event) {
        event.preventDefault();
        var type = $(event.target).closest('.navigation').data('type');
        var popupToOpen = this.popups.filter('[data-type="' + type + '"]');
        if (popupToOpen.length === 0) { return; }
        this.popups.removeClass('open');
        popupToOpen.addClass('open');
        popupToOpen.focus();
    };

    SliderNavigation.prototype.closePopup = function(event) {
        if ( !$(event.target).closest('.slider-nav, .button-menu, .button-user').length ||
            $(event.target).closest('.button-close').length ) {
            this.popups.removeClass('open')
        }
    };

    SliderNavigation.prototype.closePopups = function() {
        this.popups.removeClass('open')
    };

    function ScaleContent(el) {
        this.content = $(el).find('.container')

        this.parentHeight  = $(el).parent('.swiper-slide').height() // отступ под навигацию
        this.parentWidth  = innerWidth

        $(window).on('resize', this.scale.bind(this))

        //this.scaleHTML()
        this.scale()

    }

    ScaleContent.prototype.scale = function() {

        var scale = Math.min(
            this.parentHeight / this.getHeightContent()
        );

        scale = scale <= 1 ? scale : 1

        if (this.content.hasClass('prevent-scale') || this.parentHeight >= 768 ) {
            scale = 1
        }

        this.content.css({
            transform: 'scale('+ scale +')',
            transformOrigin: 'top left',
        })
    }

    ScaleContent.prototype.getHeightContent = function() {
        return this.content.height()
    }

    function ContactForm(el) {
        $.validator.messages.required = 'Это поле обязательно для заполнения';
        var that = this;
        this.form      = $(el);
        this.form.validate({
            errorClass: "error",
            validClass: "valid",
            rules: {
                field: {
                    required: true
                }
            },
            messages: {
                region: {
                    required: "Введите свой регион",
                },
                postav: {
                    required: "Введите хоть что-то",
                }
            },
            submitHandler: function (form) {
                $.ajax({
                    type: "POST",
                    url: "submit.php",
                    data: $(form).serialize(),
                    success: function () {
                        setTimeout(function() {
                            that.formPopup.removeClass('open');
                            sliderNav.closePopups();
                            that.form.removeClass('waiting');
                            //that.form[0].reset();
                            that.submitBtn.attr("disabled", true);
                            that.openPopupBtn.attr("disabled", true);
                            $('.success-submit').addClass('open');
                            setTimeout(function(){
                                $('.success-submit').removeClass('open');
                            },2000);
                            console.log('success');
                        },5000);
                    }
                });
                return false;
            }
        });
        this.formPopup = this.form.find('.form-popup');
        this.submitBtn = this.form.find('.button-submit').attr("disabled", true);
        this.openPopupBtn = this.form.find('.button-success').attr("disabled", true);
        this.closePopupBtn = this.form.find('.button-popup-close');

        this.openPopupBtn.on('click', this.openPopup.bind(this));
        this.closePopupBtn.on('click', this.closePopup.bind(this));
        this.form.on('change', this.checkValid.bind(this));
        this.submitBtn.on('click', this.submitForm.bind(this));
    }

    ContactForm.prototype.closePopup = function() {
        this.form.removeClass('waiting');
        this.formPopup.removeClass('open')
    };

    ContactForm.prototype.openPopup = function() {
        this.form.addClass('waiting');
        this.formPopup.addClass('open')
    };

    ContactForm.prototype.checkValid = function() {
        if (!this.form.valid()) {
            this.submitBtn.attr("disabled", true);
            this.openPopupBtn.attr("disabled", true);
        } else {
            this.submitBtn.removeAttr("disabled");
            this.openPopupBtn.removeAttr("disabled");
        }
    };

    ContactForm.prototype.submitForm = function()  {
        this.form.submit();
    };

    function UserLogout(el) {
        this.popup      = $(el);
        this.openPopupBtn = $('.button-logout');
        this.closePopupBtn = this.popup.find('.button-popup-close');
        this.openPopupBtn.on('click', this.openPopup.bind(this));
        this.closePopupBtn.on('click', this.closePopup.bind(this));
    }

    UserLogout.prototype.closePopup = function() {
        this.popup.removeClass('open')
    };

    UserLogout.prototype.openPopup = function() {
        this.popup.addClass('open')
    };

    function initSlider() {
        getCurrentSlide();
        returnSlide();
		navSlide();
		commentSlide();
        dropUp.getCurrentMenu();

        $(".scrollbar-wrapper").overlayScrollbars({ });

        $(".textarea").overlayScrollbars({textarea : {
                dynWidth       : false,
                dynHeight      : false,
            } });
    }

    function getCurrentSlide() {

        var index = mySwiper.realIndex;
        $('.swiper-container-navigation .swiper-slide').removeClass('active-nav');
        swiperNavMenu.slideTo( index, 0, false);
        $(swiperNavMenu.slides[index]).addClass('active-nav');

        var data = $(swiperNavMenu.slides[index]).data('slide');
        var el   = $('.menu .sub-menu li[data-hash='+ data +']');
        dropDownMenu.toggleActiveLink(el);


        var buttonReturn = $('.button-return');
        var returnData = $(mySwiper.slides[index]).data('return');
        buttonReturn.data('return', returnData);
		
		var buttonNav = $('.button-navto');
        var navData = $(mySwiper.slides[index]).data('navto');
        buttonNav.data('navto', navData);
    }

    function initMySwiper(){
        var slider = new Swiper ('.swiper-container-parent', {
            direction: 'horizontal',
            keyboard: true,
            init: false,
            mousewheel: true,
            navigation: {
                nextEl: '.button-next',
                prevEl: '.button-prev',
            },
            spaceBetween: 10,
            hashNavigation: {
                watchState: true,
                replaceState: true,
            },
        });

        slider.on('init', initSlider);

        slider.on('slideChange', function() {
            getCurrentSlide();
            returnSlide();
			navSlide();
			commentSlide();
            dropUp.getCurrentMenu();

            var index  = slider.activeIndex;
            var iframe = $(mySwiper.slides[index]).find('iframe');
            if (iframe && ( iframe.attr('src') !== iframe.data('src') )) {
                iframe.attr('src', iframe.data('src'))
                iframe.on('load', function() {
                    $(this).addClass('loaded');
                })
            }
        });
        return slider
    }

    function scaleContent() {
        var slider = $('.swiper-container-parent');
        var sliderH = innerHeight / 768;
        var sliderW  = innerWidth / 1024;

        var scale = Math.min(
            innerHeight / 768,
                  innerWidth / 1024

        );

        slider.css({
            position: 'absolute'//,
            /*transform: 'translate(-50%, -50%) scale('+ scale +')',*/
            /*top: '50%',*/
            /*left: '50%',*/
        })

        if (scale === 1) {
            slider.removeClass('scalled')
        } else {
            slider.addClass('scalled')
        }
    }

    $('body').animate({
        opacity: 1,
    }, 500);

    scaleContent();

    var sliderNav    = new SliderNavigation($('.slider-nav'));
    var contactForm  = new ContactForm($('.form'));
    var userLogout   = new UserLogout($('.logout'));
    var dropDownMenu = new DropDownNavigation($('.dropdown-menu .menu'));
    var dropUp       = new DropUpNavigation($('.dropup'));
    $('.write-commit').each(function() {
        new Comments(this);
    });
    $('.wrapper__container').each(function() {
        new ScaleContent(this);
    });

    swiperNavMenu = new Swiper('.swiper-container-navigation', {
        direction: 'vertical',
        spaceBetween: 15,
        slidesPerView: 'auto',
        freeMode: true,
        scrollbar: {
            el: '.swiper-scrollbar',
        },
        mousewheel: true,
    });

    swiperNavMenu.on('click', function(event) {
        var slide = $(event.target).closest('.swiper-slide');
        if (!slide.length) {
            return;
        }
        var slideData = slide.data('slide');
        var index = $('.swiper-container-parent .swiper-slide[data-hash='+ slideData +']').index();
        $('.swiper-container-navigation .swiper-slide').removeClass('active-nav');
        slide.addClass('active-nav');
        swiperNavMenu.slideTo( index, 0, false);
        mySwiper.slideTo( index, 500, false);
    });

    var startScroll, touchStart, touchCurrent;
    swiperNavMenu.slides.on('touchstart', function (e) {
        startScroll = this.scrollTop;
        touchStart = e.targetTouches[0].pageY;
    }, true);
    swiperNavMenu.slides.on('touchmove', function (e) {
        touchCurrent = e.targetTouches[0].pageY;
        var touchesDiff = touchCurrent - touchStart;
        var slide = this;
        var onlyScrolling =
            ( slide.scrollHeight > slide.offsetHeight ) && //allow only when slide is scrollable
            (
                ( touchesDiff < 0 && startScroll === 0 ) || //start from top edge to scroll bottom
                ( touchesDiff > 0 && startScroll === ( slide.scrollHeight - slide.offsetHeight ) ) || //start from bottom edge to scroll top
                ( startScroll > 0 && startScroll < ( slide.scrollHeight - slide.offsetHeight ) ) //start from the middle
            );
        if (onlyScrolling) {
            e.stopPropagation();
        }
    }, true);

    [].slice.call( document.querySelectorAll( 'button.progress-button' ) ).forEach( function( bttn ) {
        new ProgressButton( bttn, {
            callback : function( instance ) {
                var progress = 0,
                    interval = setInterval( function() {
                        progress = Math.min( progress + Math.random() * 0.1, 1 );
                        instance._setProgress( progress );

                        if( progress === 1 ) {
                            instance._stop(1);
                            clearInterval( interval );
                        }
                    }, 200 );
            }
        } );
    } );

    mySwiper = initMySwiper();
    mySwiper.init();

    function onResize(){
        if ( $(window).width() <= 1020 ) {
            if(mySwiper){
                mySwiper.destroy();
                mySwiper = null;
            }
            $('.table-container').overlayScrollbars({ });
            var data = $('.swiper-container-parent > .swiper-wrapper > .swiper-slide').eq(0).data('hash');
            var el   = $('.menu .sub-menu li[data-hash='+ data +']');
            dropDownMenu.toggleActiveLink(el);
        } else {
            if (!mySwiper) {
                mySwiper = initMySwiper();
                mySwiper.init();
                mySwiper.update();
            }
        }
    }

    $(window).on('resize', scaleContent);

    $('.button-return').on('click',function() {
       var data =  $('.button-return').data('return');
       var index = $('.swiper-container-parent .swiper-slide[data-hash='+ data +']').index();
       mySwiper.slideTo( index, 500, false);
    });
	$('.button-navto').on('click',function() {
       var data =  $('.button-navto').data('navto');
       var index = $('.swiper-container-parent .swiper-slide[data-hash='+ data +']').index();
       mySwiper.slideTo( index, 500, false);
    });

    function returnSlide() {
        var index = mySwiper.activeIndex;
        var data  = $(mySwiper.slides[index]).data('return');
        if (data) {
            $('.button-return').show()
        } else {
            $('.button-return').hide()
        }
    }
	function navSlide() {
        var index = mySwiper.activeIndex;
        var data  = $(mySwiper.slides[index]).data('navto');
        if (data) {
            $('.button-navto').show()
        } else {
            $('.button-navto').hide()
        }
    }
	function commentSlide() {
        var index = mySwiper.activeIndex;
        var data  = $(mySwiper.slides[index]).data('hash');
		document.querySelectorAll('.slide_comment').forEach(function(ta) {
			var taSlide = ta.id.split('_')[0];
			if (taSlide == data) {
				$(ta).addClass('selected');
				$('#'+ taSlide + '_comment_form').removeClass('hidden');
			} else {
				$(ta).removeClass('selected');
				$('#'+ taSlide + '_comment_form').addClass('hidden');
			}
		});		
    }

    $('.mobile-button-return').on('click',function() {
       var data  = $(this).data('return');
       var index = $('.swiper-container-parent .swiper-slide[data-hash='+ data +']');
       $('html, body').animate({
           scrollTop: (index.offset().top - 70)
       },500);
    });

    $(document).on('click','a[href^="#"]', function(event) {
        /*if ($(window).width() >= 1020) {

        } else {
            event.preventDefault();
            var data = this.hash.split('#').pop();
            if (!data) {
                return;
            }
            var index = $('.swiper-container-parent .swiper-slide[data-hash='+ data +']');
            $('html, body').animate({
                scrollTop: (index.offset().top - 70)
            },500);
        }*/

        event.preventDefault();
        var data = this.hash.split('#').pop();
        if (!data) {
            return;
        }
        var index = $('.swiper-container-parent .swiper-slide[data-hash='+ data +']').index();
        $('.swiper-container-navigation .swiper-slide').removeClass('active-nav');
        swiperNavMenu.slideTo( index, 0, false);
        mySwiper.slideTo( index, 500, false);
        var el   = $('.menu .sub-menu li[data-hash='+ data +']');
        dropDownMenu.toggleActiveLink(el);

        dropUp.close();
    });

    //onResize();

    /*window.addEventListener('orientationchange', function() {
        //var orientation = Math.abs(window.orientation) == 90 ? 'landscape' : 'portrait';

        if ($(window).width() >= 1020 && screen.orientation !== 90 || screen.orientation !== -90 ) {
            console.log('поворот');
        }

    }, false);*/
});

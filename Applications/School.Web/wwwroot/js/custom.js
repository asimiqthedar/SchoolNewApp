$(function () {
    $('.topnav-hamburger').on('click', function () {
        $('.side-menu').toggleClass('open-menu');
        $('.hamburger-icon').toggleClass('open-icon');
        $('.main-content').toggleClass('main-content-open');
        $('.header-sec').toggleClass('header-sec-open');
        $('.footer').toggleClass('footer-open');

    });
});

$(function () {
    $('.navbar-brand-box .btn-close').on('click', function () {
        $('.side-menu').removeClass('open-menu');
        $('.hamburger-icon').toggleClass('open-icon');


    });
});



var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'))
var tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
    return new bootstrap.Tooltip(tooltipTriggerEl)
})

Array.from(document.querySelectorAll("form .auth-pass-inputgroup")).forEach(function (e) { Array.from(e.querySelectorAll(".password-addon")).forEach(function (r) { r.addEventListener("click", function (r) { var o = e.querySelector(".password-input"); "password" === o.type ? o.type = "text" : o.type = "password" }) }) });

// 
$(function () {
    "use strict";
    if ($(".dd").length > 0) {
        $('.dd').nestable();

        $('.dd').on('change', function () {
            var $this = $(this);
            var serializedData = window.JSON.stringify($($this).nestable('serialize'));

            $this.parents('div.body').find('textarea').val(serializedData);
        });
    }
    if ($(".dd4").length > 0) {
        $('.dd4').nestable();

        $('.dd4').on('change', function () {
            var $this = $(this);
            var serializedData = window.JSON.stringify($($this).nestable('serialize'));
        });
    }
});

$(document).ready(function () {
    if ($(".multiple-select").length > 0) {
        var multipleCancelButton = new Choices('.multiple-select', {
            removeItemButton: true,
        });
    }
});


// Projects swiper Js

if ($(".project-swiper").length > 0) {
    var swiper = new Swiper(".project-swiper", {
        slidesPerView: 1,
        spaceBetween: 24,
        navigation: {
            nextEl: ".slider-button-next",
            prevEl: ".slider-button-prev"
        },
        breakpoints: {
            640: {
                slidesPerView: 2,
                spaceBetween: 15
            },
            768: {
                slidesPerView: 6,
                spaceBetween: 20
            },
            1200: {
                slidesPerView: 6,
                spaceBetween: 25
            }
        }
    });
}
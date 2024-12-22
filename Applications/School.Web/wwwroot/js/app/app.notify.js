$app.notify = $app.notify || {};

$app.messageBox = $app.messageBox || {};

(function () {
    toastr.options.closeButton = true;
    toastr.options.newestOnTop = true;
    toastr.options.timeOut = 10000;
    toastr.options.extendedTimeOut = 0;
    toastr.options.preventDuplicates = false;

    $app.notify.success = function (message, title) {
        toastr.remove();
        toastr.success(message, title);
    };

    $app.notify.info = function (message, title) {
        toastr.remove();
        toastr.info(message, title);
    };

    $app.notify.warn = function (message, title) {
        toastr.remove();
        toastr.warning(message, title);
    };

    $app.notify.warning = function (message, title) {
        toastr.remove();
        toastr.warning(message, title);
    };

    $app.notify.error = function (message, title) {
        toastr.remove();
        toastr.error(message, title);
    };

    $app.notify.show = function (d, view) {
        if (view) {
            $app.notify.blockMessage(view, d.Type, d.Message, d.Title)
            return;
        }
        if (d.Type == 'error')
            $app.notify.error(d.Message, d.Title);
        else if (d.Type == 'warn')
            $app.notify.warn(d.Message, d.Title);
        else if (d.Type == 'success')
            $app.notify.success(d.Message, d.Title);
        else
            $app.notify.info(d.Message, d.Title);
    };

    $app.notify.blockMessage = function (type, message, title, op) {
        op = op || {};
        if (op.withNewPage) {
            var pv_msgs = sessionStorage.getItem('_pending_messages_');
            if (pv_msgs) {
                var a_m = JSON.parse(pv_msgs);
                a_m.push({ Type: type, Message: message, Title: title });
                sessionStorage.setItem('_pending_messages_', JSON.stringify(a_m));
            }
            else {
                var a_m = [{ Type: type, Message: message, Title: title }];
                sessionStorage.setItem('_pending_messages_', JSON.stringify(a_m));
            }
        }
        else {
            var cls = "alert-" + type;
            if (type == 'error')
                cls = "alert-danger";
            var h = "<div class='alert " + cls + " alert-block'><a class='close' data-dismiss='alert' href='#'>×</a>";
            if (title)
                h += "<h4 class='alert-heading'>" + title + "</h4>";
            h += "" + message + "</div>"
            $(h).insertBefore($('#main_container').children().first());
        }
    };

    $app.notify.showWithNewPage = function (d) {
        var cls = "alert-" + d.Type,
            title = d.Title || "";
        if (d.Type == 'error')
            cls = "alert-danger";
        var h = "<div>" +
            "<div class='alert " + cls + " alert-block'><h4 class='alert-heading'>" + title + "</h4>" + d.Message + "</div>" +
            "<div class='row'><div class='col-sm-12' style='text-align:center'><a href='" + $app.hostUrl + "/Home/Index' class='btn btn-info'>Go to Home</a></div></div>" +
            "</div>";
        $('#main_container').html(h);
        $app.ui.PageFooterResize();
    };

    $app.notify.clear = function (view) {
        if (view) {
            $(view).find('.alert-block').remove();
        }
        toastr.clear();
    };

    $(document).on('click', 'input[type="text"],input[type="radio"],input[type="checkbox"],textarea', function () {
        $app.notify.clear();
    });

    $app.notify.setStatus = function (sts) {
        $('#site-status').css("display", "inline").html(sts);
    };

    $app.notify.clearStatus = function () { $('#site-status').css("display", "none"); };


    $app.notify.validate = function (_ctrlId, msg, isRemove) {
        if (isRemove) {
            $("#_validate_" + _ctrlId).remove();
            $("#" + _ctrlId).removeAttr("style")
        }
        else {
            if (!($("#" + _ctrlId).attr("style"))) {
                $("#" + _ctrlId).css("border-color", "#E02E40");
                $("#" + _ctrlId).after('<span class="form-control control-errormessage" style="" id="_validate_' + _ctrlId + '">' + msg + '</span>');
                $("#" + _ctrlId).on('keyup', function () {
                    if ($(this).val() != null && $(this).val() != '' && $(this).val().trim() != '') {
                        $("#_validate_" + $(this).attr('id')).remove();
                        $(this).removeAttr("style");
                    }
                    //else {
                    //    if (!($("#" + _ctrlId).attr("style"))) {
                    //        $(this).css("border-color", "#E02E40");
                    //        $(this).after('<span class="form-control control-errormessage" id="_validate_' + _ctrlId + '">' + msg + '</span>');
                    //    }
                    //}
                });
            }
            $app.messageBox.setFocusToControl(_ctrlId);
        }
    }

    $app.notify.validateObject = function (_ctrlObj, msg, isRemove) {
        if (isRemove) {
            $(_ctrlObj).closest('div').find(".validateSpan").remove();
            $(_ctrlObj).removeClass("error-control");
            $(_ctrlObj).closest('div').removeClass("error-control-container");
        }
        else {
            if (!($(_ctrlObj).hasClass("error-control"))) {
                $(_ctrlObj).addClass("error-control");
                $(_ctrlObj).closest('div').addClass("error-control-container");
                $(_ctrlObj).after('<span class="form-control control-errormessage validateSpan">' + msg + '</span>');
                $(_ctrlObj).on('keyup change', function () {
                    if ($(this).val() != null && $(this).val() != '' && $(this).val().trim() != '') {
                        $(this).closest('div').find(".validateSpan").remove();
                        $(this).removeClass("error-control");
                        $(this).closest('div').removeClass("error-control-container");
                    }
                });
            }
            $app.messageBox.setFocusToControlObject(_ctrlObj);
        }
    }

    $app.notify.validatewitherror = function (_ctrlId, _grpId, msg, isRemove) {
        if (isRemove) {
            $("#_validate_" + _ctrlId).remove();
            $("#" + _ctrlId).removeAttr("style")
        }
        else {
            if (!($("#" + _ctrlId).attr("style"))) {
                $("#" + _ctrlId).css("border-color", "#E02E40");
                $("#" + _grpId).after('<span class="form-control errormsg" id="_validate_' + _ctrlId + '">' + msg + '</span>&nbsp;');
                $("#" + _ctrlId).on('keyup', function () {
                    if ($(this).val() != null && $(this).val() != '' && $(this).val().trim() != '') {
                        $("#_validate_" + $(this).attr('id')).remove();
                        $(this).removeAttr("style");
                    }
                    else {
                        if (!($("#" + _ctrlId).attr("style"))) {
                            $(this).css("border-color", "#E02E40");
                            $("#" + _grpId).after('<span class="form-control errormsg" id="_validate_' + _ctrlId + '">' + msg + '</span>&nbsp;')
                        }
                    }
                });
                if ($("#" + _ctrlId).is(':checkbox')) {
                    $("#" + _ctrlId).on('click', function () {
                        if ($(this).is(':checked')) {
                            $("#_validate_" + $(this).attr('id')).remove();
                            $(this).removeAttr("style");
                        }
                        else {
                            if (!($("#" + _ctrlId).attr("style"))) {
                                $(this).css("border-color", "#E02E40");
                                $("#" + _grpId).after('<span class="form-control errormsg" id="_validate_' + _ctrlId + '">' + msg + '</span>&nbsp;');
                            }
                        }
                    });
                }
            }
            $app.messageBox.setFocusToControl(_ctrlId);
        }
    }

    $app.notify.validateGroup = function (_ctrlId, _grpId, msg, isRemove) {
        if (isRemove) {
            $("#_validate_" + _ctrlId).remove();
            $("#" + _ctrlId).removeAttr("style")
        }
        else {
            if (!($("#" + _ctrlId).attr("style"))) {
                $("#" + _ctrlId).css("border-color", "#E02E40");
                $("#" + _grpId).after('<span class="form-control control-errormessage" id="_validate_' + _ctrlId + '">' + msg + '</span>&nbsp;');
                $("#" + _ctrlId).on('keyup', function () {
                    if ($(this).val() != null && $(this).val() != '' && $(this).val().trim() != '') {
                        $("#_validate_" + $(this).attr('id')).remove();
                        $(this).removeAttr("style");
                    }
                    else {
                        if (!($("#" + _ctrlId).attr("style"))) {
                            $(this).css("border-color", "#E02E40");
                            $("#" + _grpId).after('<span class="form-control control-errormessage" id="_validate_' + _ctrlId + '">' + msg + '</span>&nbsp;')
                        }
                    }
                });
                if ($("#" + _ctrlId).is(':checkbox')) {
                    $("#" + _ctrlId).on('click', function () {
                        if ($(this).is(':checked')) {
                            $("#_validate_" + $(this).attr('id')).remove();
                            $(this).removeAttr("style");
                        }
                        else {
                            if (!($("#" + _ctrlId).attr("style"))) {
                                $(this).css("border-color", "#E02E40");
                                $("#" + _grpId).after('<span class="form-control control-errormessage" id="_validate_' + _ctrlId + '">' + msg + '</span>&nbsp;');
                            }
                        }
                    });
                }
            }
            $app.messageBox.setFocusToControl(_ctrlId);
        }
    }

    $app.notify.validateDD = function (_ctrlId, msg, isRemove) {
        if (isRemove) {
            $("#_validate_" + _ctrlId).remove();
            $("#" + _ctrlId).removeAttr("style")
        }
        else {
            if (!($("#" + _ctrlId).attr("style"))) {
                $("#" + _ctrlId).css("border-color", "#E02E40");
                $("#" + _ctrlId).after('<span class="form-control control-errormessage" id="_validate_' + _ctrlId + '">' + msg + '</span>');
                $("#" + _ctrlId).on('change', function () {
                    if ($(this).val() != null && $(this).val() != '' && $(this).val().trim() != '') {
                        $("#_validate_" + $(this).attr('id')).remove();
                        $(this).removeAttr("style");
                    }
                    else {
                        if (!($("#" + _ctrlId).attr("style"))) {
                            $(this).css("border-color", "#E02E40");
                            $(this).after('<span class="form-control control-errormessage" id="_validate_' + _ctrlId + '">' + msg + '</span>');
                        }
                    }
                });
            }
            $app.messageBox.setFocusToControl(_ctrlId);
        }
    }

    $app.notify.validateRadioGroup = function (_ctrlClass, _grpId, msg, isRemove) {
        if (isRemove) {
            $("#_validate_" + _ctrlClass).remove();
            $("#" + _grpId).removeAttr("style")
        }
        else {
            if (!($("#" + _grpId).attr("style"))) {
                $("#" + _grpId).css("border", "1px solid #E02E40");
                $("#" + _grpId).after('<span class="form-control control-errormessage" id="_validate_' + _ctrlClass + '">' + msg + '</span>&nbsp;')
                $("." + _ctrlClass).on('keyup', function () {
                    if ($("." + _ctrlClass + ":checked").length > 0) {
                        $("#_validate_" + _ctrlClass).remove();
                        $("#" + _grpId).removeAttr("style");
                    }
                    else {
                        if (!($("#" + _grpId).attr("style"))) {
                            $("#" + _grpId).css("border", "1px solid #E02E40");
                            $("#" + _grpId).after('<span class="form-control control-errormessage" id="_validate_' + _ctrlClass + '">' + msg + '</span>&nbsp;')
                        }
                    }
                });
                $("." + _ctrlClass).on('click', function () {
                    if ($("." + _ctrlClass + ":checked").length > 0) {
                        $("#_validate_" + _ctrlClass).remove();
                        $("#" + _grpId).removeAttr("style");
                    }
                    else {
                        if (!($("#" + _grpId).attr("style"))) {
                            $("#" + _grpId).css("border", "1px solid #E02E40");
                            $("#" + _grpId).after('<span class="form-control control-errormessage" id="_validate_' + _ctrlClass + '">' + msg + '</span>&nbsp;')
                        }
                    }
                });
            }
            $app.messageBox.setFocusToControl(_grpId);
        }
    }

    $app.messageBox.setFocusToControl = function (_control) {
        var ctrls = $('span.form-control.control-errormessage:first').closest('div').find('input,select,textarea');
        if (ctrls.length > 0) {
            var controlId = ctrls.eq(0).attr('id');
            if ($('#' + controlId).closest('div.modal-dialog').length > 0) {
                $('#' + controlId).focus();
            }
            else {
                if ($("#divMainContainer").length > 0) {
                    var label = $('#' + controlId).closest('div').find('label');
                    if (label.length > 0)
                        $("#divMainContainer").mCustomScrollbar("scrollTo", label.eq(0));
                    else
                        $("#divMainContainer").mCustomScrollbar("scrollTo", '#' + controlId);
                }
                $('#' + controlId).focus();
            }
        }

        //expand parent accordion if there is any error
        if ($('#' + _control).closest('div.collapse').length > 0 && !$('#' + _control).closest('div.collapse').hasClass('show')) {
            $('#' + _control).closest('div.collapse').parent('div').find('div[data-toggle="collapse"]').click();
        }
    }

    $app.messageBox.setFocusToControlObject = function (_controlObject) {
        var ctrls = $('span.form-control.control-errormessage:first').closest('div').find('input,select,textarea');
        if (ctrls.length > 0) {
            if ($(_controlObject).closest('div.modal-dialog').length > 0) {
                $(_controlObject).closest('div.modal-dialog').find('span.form-control.control-errormessage:first').closest('div').find('input[type=text],select,textarea').eq(0).focus();
            }
            else {
                if ($("#divMainContainer").length > 0) {
                    var label = $(_controlObject).closest('div').find('label');
                    if (label.length > 0)
                        $("#divMainContainer").mCustomScrollbar("scrollTo", label.eq(0));
                    else
                        $("#divMainContainer").mCustomScrollbar("scrollTo", _controlObject);
                }
                $(_controlObject).focus();
            }
        }

        //expand parent accordion if there is any error
        if ($(_controlObject).closest('div.collapse').length > 0 && !$(_controlObject).closest('div.collapse').hasClass('show')) {
            $(_controlObject).closest('div.collapse').parent('div').find('div[data-toggle="collapse"]').click();
        }
    }

    $app.messageBox.success = function (message, _title, callback) {
        if (!_title) {
            _title = "Success";
        }
        Lobibox.alert('success', {
            msg: message,
            title: _title
        });
        if (callback != undefined && typeof callback == 'function') {
            $(".lobibox-btn.lobibox-btn-default").on('click', function () {
                callback();
            });
        }
    };

    $app.messageBox.info = function (message, _title) {
        if (!_title) {
            _title = "Information";
        }
        Lobibox.alert('info', {
            msg: message,
            title: _title
        });
    };

    $app.messageBox.warn = function (message, _title) {
        $app.messageBox.warning(message, _title);
    };

    $app.messageBox.warning = function (message, _title) {
        if (!_title) {
            _title = "Warning";
        }
        Lobibox.alert('warning', {
            msg: message,
            title: _title
        });
    };

    $app.messageBox.error = function (message, _title, callback) {
        if (!_title) {
            _title = "Error";
        }
        Lobibox.alert('error', {
            msg: message,
            title: _title
        });
        if (callback != undefined && typeof callback == 'function') {
            $(".lobibox-btn.lobibox-btn-default").on('click', function () {
                callback();
            });
        }
    };


    $app.notify.replaceInformationIcon = function () {
        $(".spInfoTA").html($("#divIcon").html());
        $(".spInfoTA").each(function (ele) {
            $(this).find("#aPopOver").popover().on("show.bs.popover", function () {
                $($(this).data("bs.popover").getTipElement()).css({
                    maxWidth: "400px"
                });
            }).on('mouseenter', function () {
                var _this = this;
                $(this).popover('show');
                $('.popover').on('mouseleave', function () {
                    $(_this).popover('hide');
                });
            }).on('mouseleave', function () {
                var _this = this;
                setTimeout(function () {
                    if (!$('.popover:hover').length) {
                        $(_this).popover('hide');
                    }
                }, 300);
            }).on("click", function () {
                var _this = this;
                if ($(_this).hasClass('onclick')) {
                    $(_this).popover('hide');
                    $(_this).removeClass('onclick');
                }
                else {
                    $(_this).addClass('onclick');
                    $(_this).popover('show');
                }
                $('.popover').on('mouseleave', function () {
                    $(_this).popover('hide');
                });
            }).on("blur", function () {
                var _this = this;
                setTimeout(function () {
                    if (!$('.popover:hover').length) {
                        $(_this).removeClass('onclick');
                        $(_this).popover('hide');
                    }
                }, 300);
            });
        });
    }

    setTimeout(function () {
        if ($("#divAlertContainer .alert").length > 0) {
            $("#divAlertContainer .alert").each(function () {
                if ($(this).hasClass('alert-danger'))
                    $app.messageBox.error($(this).text());
                else if ($(this).hasClass('alert-warning'))
                    $app.messageBox.warn($(this).text());
                else if ($(this).hasClass('alert-info'))
                    $app.messageBox.info($(this).text());
                else if ($(this).hasClass('alert-success'))
                    $app.messageBox.success($(this).text());
            });
        }
    }, 1000);

})();
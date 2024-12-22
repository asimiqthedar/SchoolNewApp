(function ($) {
    $app.get = function (url, parm, op) {
        op = (op) ? op : {};
        //$app.ui.block(op.blockElm);
        url = $app.hostUrl  + url;
        return $.Deferred(function ($dfd) {
            $.get(url, parm)
                .done(function (data, xyz, xhr) {
                    handleAjaxDone.bind(this)(op, $dfd, data, xhr);
                }).fail(function (x, y, z) {
                    handleAjaxError.bind(this)(op, $dfd, x);
                }).always(function () {
                    //$app.ui.unblock(op.blockElm);
                });
        });
    };

    $app.post = function (url, data, op) {
        op = (op) ? op : {};
        //$app.ui.block(op.blockElm);
        return $.Deferred(function ($dfd) {
            $.post($app.hostUrl  + url, data)
                .done(function (dt, status, xhr) {
                    handleAjaxDone.bind(this)(op, $dfd, dt, xhr);
                }).fail(function (x, y, z) {
                    handleAjaxError.bind(this)(op, $dfd, x);
                }).always(function () {
                    //$app.ui.unblock(op.blockElm);
                });
        });
    };

    $app.ajax = function (url, op) {
        op = (op) ? op : {};
        //$app.ui.block(op.blockElm);
        return $.Deferred(function ($dfd) {
            $.ajax({
                url: $app.hostUrl + url,
                type: op.type || 'POST',
                contentType: op.contentType || "application/json; charset=utf-8",
                data: op.data,
                success: function (dt, xyz, xhr) {
                    handleAjaxDone.bind(this)(op, $dfd, dt, xhr);
                }
            }).fail(function (x) {
                handleAjaxError.bind(this)(op, $dfd, x);
            }).always(function () {
                //$app.ui.unblock(op.blockElm);
            });
        });
    };

    $app.ajaxForm = function (url, formData, op) {
        op = (op) ? op : {};
        //$app.ui.block(op.blockElm);
        return $.Deferred(function ($dfd) {
            $.ajax({
                url: $app.hostUrl + url,
                type: 'POST',
                cache: false,
                contentType: false,
                processData: false,
                data: formData,
                success: function (dt, xyz, xhr) {
                    handleAjaxDone.bind(this)(op, $dfd, dt, xhr);
                }
            }).fail(function (x) {
                handleAjaxError.bind(this)(op, $dfd, x);
            }).always(function () {
                //$app.ui.unblock(op.blockElm);
            });
        });
    };

    $app.openViewDialog = function (_url, _op) {
        _op = (_op) ? _op : {};
        var dlg;
        _url = $app.hostUrl + _url;
        dlg = bootbox.dialog({
            message: "Init",
            draggable: true,
            //backdrop: true,
            title: (_op.title ? _op.title : "-"),
            onEscape: function () {
                //if ($app._currViewDialog_.length > 0)
                //    $app._currViewDialog_.pop();
                //_op.onEscape();
            },
            buttons: _op.buttons
        });
        $app._currViewDialog_.push(dlg);
        dlg.on("hidden.bs.modal", function (e) {
            if ($app._currViewDialog_.length > 0)
                $app._currViewDialog_.pop();
            if (_op.onEscape)
                _op.onEscape();
        });
        dlg.find(".modal-dialog").addClass("modal-lg");
        if (_op.customClass) {
            dlg.find(".modal-dialog").addClass(_op.customClass);
        }
        if (_op.uniformClass) {
            dlg.find(".modal-dialog").addClass(_op.uniformClass);
        }
        if (!_op.title)
            dlg.find(".modal-title").remove();
        dlg.find(".modal-header").css('padding', '0px 15px 5px');
        $.ajax({
            url: _url,
            type: "GET",
            dataType: "html",
            beforeSend: function (xhr) {
                dlg.find('.bootbox-body').html("<h4><i class='fa fa-spinner fa-spin'></i> Loading..</h1>");
            },
            success: function (data) {
                if (checkData(data)) {
                    dlg.find('.bootbox-body').html(data);
                }
            },
            error: function (xh, sts, err) {
                dlg.find('.bootbox-body').html('<h4><i class="fa fa-warning txt-color-orangeDark"></i> Error: ' + err + '</h1>');
            }
        }).always(function () {
            //$(".modal-content").draggable();
        });
        dlg.find('.modal-content').draggable({
            handle: '.modal-header'
        });
        return dlg;
    };

    $app._currViewDialog_ = [];
    $app.getCurrentViewDialog = function () {
        if ($app._currViewDialog_.length > 0)
            return $app._currViewDialog_[$app._currViewDialog_.length - 1];
        else return null;
    }

    $.fn.loadViewPage = function (_url, _op) {
        var current = $(this);
        _op = (_op) ? _op : {};
        var __async = (_op._async == null || _op._async == undefined) ? true : _op._async;
        _url = $app.hostUrl + "/" + _url;
        $.ajax({
            url: _url,
            beforeSend: function () {
                current.html('<h4 class="ajax-loading-animation"><i class="fa fa-cog fa-spin"></i> Loading...</h1>');
            },
            async: __async,
            type: "GET",
            dataType: "html",
            success: function (data) {
                if (checkData(data)) {
                    current.html(data);
                }
                if (_op.afterload != undefined) _op.afterload(data);
            },
            error: function (xh, sts, err) {
                current.html('<h4 class="ajax-loading-error"><i class="fa fa-warning txt-color-orangeDark"></i> Error ' + err + '</h4>');
            }
        }).always(function () { });
        return this;
    };

    $.fn.initAjaxSubmit = function (op) {
        op = op || {};
        var form = $(this);
        form.on('submit', function (e) {
            e.preventDefault();
            form.validate();
            if (!form.valid())
                return;
            if (!op.validate())
                return;
            var _url = form.attr('action');
            //$app.ui.block(op.blockElm);
            $.ajax({
                type: "POST",
                url: _url,
                data: form.serialize(), // serializes the form's elements.
                success: function (data, x) {
                    //$app.ui.unblock(op.blockElm);
                    if (data && typeof data === 'object') {
                        if (data.Exception) {
                            if (!op.handleError) {
                                handlerror(data);
                            }
                            op.onError(data);
                        }
                        else if (data.RedirectUrl) {
                            let _RedirectUrl = $app.AddPc(data.RedirectUrl);
                            location.href = $app.hostUrl + _RedirectUrl;
                        }
                        else {
                            showServerMessages(data.Messages);
                            op.onSuccess(data.Data, data);
                        }
                    }
                    if (data === '#SessionExpire#') {
                        window.location.reload(true);
                    }
                    //else
                    //$.mainContent.html(data);                    
                },
                error: function (xh, sts, err) {
                    //$app.ui.unblock(op.blockElm);
                    if (!op.handleError) {
                        handlerror(xh.responseJSON);
                    }
                    op.onError(xh.responseJSON);
                }
            });
        });
    };


    var handleAjaxDone = function (op, $dfd, data, xhr) {
        if (xhr && xhr.getResponseHeader("X-Responded-JSON") != null
            && JSON.parse(xhr.getResponseHeader("X-Responded-JSON")).status == "401") {
            window.location.href = $app.hostUrl + '/Auth/UnAuthorizeAccess';
            return false;
        }
        var dt = data.__type == 'json' ? data.Data : data;
        if (typeof data === 'object' && data.Exception) {
            handleAjaxError.bind(this)(op, $dfd, data);
            return;
        }
        else if (typeof data === 'object' && data.RedirectUrl) {
            let _RedirectUrl = $app.AddPc(data.RedirectUrl);
            location.href = $app.hostUrl + _RedirectUrl;
            return;
        }
        if (checkData(dt)) {
            showServerMessages(data.Messages);
            $dfd && $dfd.resolve(dt, data);
        }
        else {
            //handleAjaxError.bind(this)(op, $dfd, data);
            $dfd.reject.apply(this, arguments);
        }
    };

    var handleAjaxError = function (op, $dfd, err_ob) {
        if (!op.handleError) {
            //$app.ui.unblock(op.blockElm);
            handlerror(err_ob);
        }
        $dfd.reject.apply(this, [err_ob]);
    }

    var checkData = function (dt) {
        if (dt === "#UnAuthorizedAccess#") {
            window.location.href = $app.hostUrl + '/Auth/UnAuthorizeAccess';
            return false;
        }
        else if (dt === "#ActiveAnoterUser#") {
            window.location.href = $app.hostUrl + '/Auth/ActiveAnoterUser';
            return false;
        }
        else if (dt === "#SessionExpire#") {
            window.location.href = $app.hostUrl + '/Auth/SessionExpire';
            return false;
        }
        else if (dt === "#PreventProcess#") {
            window.location.href = $app.hostUrl + '/Home/UnderConstruction';
            return false;
        }
        else if (typeof dt === "string" && dt.indexOf("#InvalidProcess#") >= 0) {
            window.location.href = $app.hostUrl + '/ArticleProcess/StatusChanged';
            return false;
        }
        return true;
    };

    var showServerMessages = function (msgs) {
        var lvl = function (m) {
            if (m == 2) return 'error';
            else if (m == 3) return 'warn';
            else if (m == 4) return 'success';
            else return 'info';
        };
        if (msgs)
            _.each(msgs, function (m) { $app.messageBox[lvl(m.Level)](m.Message); });
    };

    $app.handldatatableerror = function (x) {
        if (x.responseText === "UnAuthorizedAccess") {
            window.location.href = $app.hostUrl + '/Auth/UnAuthorizeAccess';
        }
        else if (x.responseJSON && x.responseJSON.Exception) {
            $app.messageBox.error(x.responseJSON.Message);
        }
    };

    var handlerror = function (x, view) {
        var msg = 'Bad Request.'; ti = 'Error';
        if (x && x.Exception) {
            msg = x.Message;
            if (x.ExceptionType == 'MessageException') {
                showServerMessages([msg]);
            }
            else {
                if (msg.indexOf('provided anti-forgery token was meant for a different claims-based user') > 0) {
                    $app.messageBox.error("This page has been expired, please click on 'Ok' to continue", ti, function () {
                        window.location.reload(true);
                    });
                }
                else
                    $app.messageBox.error(msg, ti);
            }
        }
        else
            $app.messageBox.error(msg, ti);
    };

    //$app.fileDownload = function (_url, _op) {
    //    _url = $app.hostUrl + "/" + _url;
    //    $.fileDownload(_url, {
    //        preparingMessageHtml: "We are preparing your report, please wait...",
    //        failCallback: function (html, url) {
    //            $app.messageBox.error('Your report download just failed.', ti);
    //            //alert('Your report download just failed.');
    //        }
    //    });
    //};

    //$app.uploadFile = function (file, path, name) {
    //    if (file == null) return;
    //    $app.notify.setStatus('uploading..');
    //    var data = new FormData();
    //    data.append("UploadedFile", file);
    //    var ajaxRequest = $.ajax({
    //        type: "POST",
    //        url: "/api/File/UploadFile?" + $.param({ path: path, filename: name }),
    //        contentType: false,
    //        processData: false,
    //        data: data
    //    }).always(function () { $app.notify.clearStatus(); });
    //    return ajaxRequest;
    //};
    //**Block UI

    //$.extend($.blockUI.defaults, {
    //    message: ' ',
    //    css: {},
    //    overlayCSS: {
    //        backgroundColor: '#AAA',
    //        opacity: 0.3,
    //        cursor: 'wait'
    //    }
    //});

    //$app.ui.block = function (elm) {
    //    if (!elm) {
    //        $('#progress_panel').css({ "display": "block" });
    //        $.blockUI({ baseZ: 2000 });
    //    } else {
    //        var elm_h = $("<div/>").addClass('spinner-sm').css({ top: '40%', left: '45%', position: 'absolute', color: '#7a6c83' }).html('<i class="fa fa-circle-o-notch fa-spin fa-3x fa-fw"></i>');
    //        $(elm).block();
    //        $(elm).append(elm_h);
    //    }
    //};

    //$app.ui.unblock = function (elm) {
    //    if (!elm) {
    //        $.unblockUI();
    //        $('#progress_panel').css({ "display": "none" });
    //    } else {
    //        $(elm).find('.spinner-sm').remove();
    //        $(elm).unblock();
    //    }
    //};
    //*********************
})(jQuery);
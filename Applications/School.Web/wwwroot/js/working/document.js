
function UploadDocs() {
    let isError = false;
    if (!$("#txtDocNumber").val() || !$("#txtDocNumber").val()) {
        $app.notify.validate("txtDocNumber", "Doc Number is required");
        isError = true;
    }
    if (!$("#fdAttachments").val() || !$("#fdAttachments").val()) {
        $app.notify.validate("fdAttachments", "Task Attachments is required");
        isError = true;
    }
    if (!isError) {
        var formData = new FormData();
        formData.append("attachment", $("#fdAttachments")[0].files[0]);
        formData.append("DocFor", parseInt($("#DocFor").val()));
        formData.append("DocType", parseInt($("#DocType").val()));
        formData.append("DocForId", parseInt($("#DocForId").val()));
        formData.append("DocNo", $("#txtDocNumber").val());
        var url = baseUrl + 'Attachment/UploadAttachment';
        $.post({
            url: url,
            data: formData,
            processData: false,
            contentType: false,
            success: function (response) {
                if (response.result == 0) {
                    bootbox.hideAll();
                    $("#fdAttachments").val("");
                    $("#txtDocNumber").val("");
                    LoadAttachments(parseInt($("#DocForId").val()), parseInt($("#DocFor").val()));
                }
                else {
                    $app.notify.error("Error!");
                }
            },
            error: function (jqXHR, textStatus, errorThrown) {
                $app.notify.error("Error!");
            }
        });
    }
}
function LoadAttachments(docForId, docFor) {
    $('#dvAttachments').empty();
    var url = baseUrl + 'Attachment/GetAttachmentPartial?docForId=' + parseInt(docForId) + "&docFor=" + parseInt(docFor);
    $('#dvAttachments').load(url);
}
function DeleteDocument(uploadedDocId, docForId, docFor) {
    var dlg_removeTask = bootbox.dialog({
        message: 'Are you sure you want to remove this?',
        title: 'Remove',
        buttons: {
            ok: {
                label: "Yes",
                className: 'btn-primary',
                callback: function () {
                    var urlToCall = baseUrl + 'Attachment/DeleteAttachment';
                    urlToCall = urlToCall + '?uploadedDocId=' + uploadedDocId;

                    $app.get(urlToCall).then(function (response) {
                        console.log(response)
                        if (response.result == 0) {
                            //$app.notify.success("Data has been deleted!");
                            LoadAttachments(docForId, docFor);
                        }
                        else {
                            $app.notify.error("Error!");
                        }
                    });
                }
            },
            cancel: {
                label: "No",
                className: 'btn-danger',
                callback: function () {
                    $(dlg_removeTask).modal('hide');
                }
            }
        }
    });
}
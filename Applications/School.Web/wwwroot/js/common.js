function ConvertDateTimestamp(dateString) {
    if (dateString != null) {
        var date = new Date(dateString);
        var timestamp = date.getTime();
        return timestamp;
    }
    else
        return null;
}
function ExportCSV(reportKey,reportName) {
    var form = $('<form>', {
        'action': baseUrl + 'Report/DownloadReport?reportName=' + reportName, 
        'method': 'POST',
        'target': '_blank' // Open response in new tab
    });
    form.append($('<input>', {
        'type': 'hidden',
        'name': 'ReportKey', 
        'value': reportKey 
    }));
    form.append($('<input>', {
        'type': 'hidden',
        'name': 'ReportName',
        'value': reportName
    }));
    // Submit the form
    $('body').append(form);
    form.submit();
    //var urlToCall = baseUrl + 'Report/DownloadReport?reportName=' + reportName;
    //$app.post(urlToCall).then(function (response) {
    //    //alert();
    //});
}
function ExportCSVWithParam(reportKey, reportName, parameters) {
    var form = $('<form>', {
        'action': baseUrl + 'Report/DownloadReport?reportName=' + reportName,
        'method': 'POST',
        'target': '_blank' // Open response in new tab
    });
    form.append($('<input>', {
        'type': 'hidden',
        'name': 'ReportKey',
        'value': reportKey
    }));
    form.append($('<input>', {
        'type': 'hidden',
        'name': 'ReportName',
        'value': reportName
    }));
    form.append($('<input>', {
        'type': 'hidden',
        'name': 'Parameters',
        'value': parameters
    }));
    // Submit the form
    $('body').append(form);
    form.submit();
    //var urlToCall = baseUrl + 'Report/DownloadReport?reportName=' + reportName;
    //$app.post(urlToCall).then(function (response) {
    //    //alert();
    //});
}
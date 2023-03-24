(function ($) {
    function _toggleColumn(_parent) {

    }
    var methods = {
        init: function (options) {
            return this.each(function () {
                var _parent = $(this);
                var _settings = $.extend(true, {
                    pageSize: 20,
                    dataCount: 0,
                    onPageSizeChanged: function () { },
                    onActivePageChanged: function () { },
                    onRowSelected: function () { },
                    onColumnHidden: function () { },
                    onColumnVisible: function () { },
                    onRowDeleted: function () { },
                    onUploadInitiated: function () { },
                    onDownloadInitiated: function () { },
                    onAdditionPerformed: function () { },
                    onDeletionPerformed: function () { }
                }, options);
                _parent.data("_psettings", _settings);

                var tbody = _parent.find("tbody").first();
                tbody.find("tr").hide().slice(0, _settings.pageSize).show();
                var captionCols = _parent.find("tr.captions th");
                captionCols.filter(".select-column").children("i").click(function () {
                    var element = $(this);
                    var checked = element.hasClass("fa-check-square-o");
                    if (checked) {
                        element.removeClass("fa-check-square-o").addClass("fa-square-o");
                        tbody.find("td.select-column i").removeClass("fa-check-square-o").addClass("fa-square-o");
                        tbody.find("tr").removeClass("active");
                    } else {
                        element.removeClass("fa-square-o").addClass("fa-check-square-o");
                        tbody.find("td.select-column i").removeClass("fa-square-o").addClass("fa-check-square-o");
                        tbody.find("tr").addClass("active");
                    }
                });

                var colSelects = _parent.find("th.command-column ul.dropdown-menu");
                colSelects.click(function (e) {
                    e.stopPropagation();
                });
                colSelects.find("a").click(function (e) {
                    e.preventDefault();
                    var element = $(this);
                    var checked = false;
                    var icon = element.children("i").first();
                    if (icon.hasClass("fa-square-o")) {
                        checked = true;
                        icon.removeClass("fa-square-o").addClass("fa-check-square-o");
                    } else {
                        icon.removeClass("fa-check-square-o").addClass("fa-square-o");
                    }
                    var name = element.attr("data-name");
                    if (checked) {
                        captionCols.filter("th[data-name='" + name + "']").show();
                        tbody.find("td[data-column='" + name + "']").show();
                    } else {
                        captionCols.filter("th[data-name='" + name + "']").hide();
                        tbody.find("td[data-column='" + name + "']").hide();
                    }
                });

                tbody.find("td.select-column i.fa").click(function () {
                    var element = $(this);
                    var checked = element.hasClass("fa-check-square-o");
                    if (checked) {
                        element.removeClass("fa-check-square-o").addClass("fa-square-o");
                        element.parents("tr").removeClass("active");
                        captionCols.filter(".select-column").children("i").removeClass("fa-check-square-o fa-square-o").addClass("fa-square-o");
                    } else {
                        element.removeClass("fa-square-o").addClass("fa-check-square-o");
                        element.parents("tr").addClass("active");
                    }
                });
            });
        }
    };
    $.fn.tdkDataTable = function (options, args) {
        var _parent = $(this);
        if (!_parent.data("_psettings")) {
            return methods.init.call(this, options);
        } else if (methods[options]) {
            return methods[options].call(this, args);
        }
    }
})(jQuery);
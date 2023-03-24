/***
    Author : alfarizi.indonesia@gmail.com
    Created : 07.09.2015
    Description : Implementation of fixed table (with freeze column and header) Ver. 2.
*/

var isBaseVerticalScrolled = false;
var isBaseHorizontalScrolled = false;
var isColumnFixed = false;
var isRowFixed = false;

var baseTableColumnWidth = 0;
$.setBaseTableWidth = function (baseTable, baseViewport) {
    $(baseTable).css("width", "");

    baseTableColumnWidth = 0;
    var baseTableHeader = $(baseTable).first('thead tr');
    $(baseTableHeader).find('th').each(function (columnIndex, column) {
        baseTableColumnWidth = baseTableColumnWidth + $(column).width();
    });

    $(baseTable).css("width", (baseTableColumnWidth <= $(baseViewport).width()) ? "auto" : "100%");
};

/***
    Call remakeFixedTable function on callback.
*/
$.remakeFixedTable = function () {

    $.initFixedTable();
    $.resetFixedTable();
};
$.initFixedTable = function () {
    /***
        Get fixed table element
        1. JavaScript document.getElementsByClassName(className)[0] more accurate
           than using jQuery $(document).find(className). jQuery always return object
           which maybe is undefined object. use JavaScirpt method if you want to check
           whether the object is undefined (doesn't exist);
    */

    var mainContainer = document.getElementsByClassName("afixed-main-container")[0];
    if (mainContainer !== undefined) {
        var baseContainer = $(mainContainer).find(".afixed-table-container")[0];
        var baseViewport = $(mainContainer).find(".afixed-table-viewport")[0];
        var baseTable = $(mainContainer).find(".afixed-table")[0];
        $(baseContainer).css("zIndex", 100);

        //// Create duplicate layer for fixed header ////
        var fixedHeaderContainer = $(mainContainer).find("#" + $(baseContainer).attr('id') + "-header-mask")[0];

        // remove if already exists previous column mask container.
        if (fixedHeaderContainer !== undefined) {
            $(fixedHeaderContainer).remove();
        }

        fixedHeaderContainer = $(baseContainer).clone();

        $(fixedHeaderContainer).attr("id", $(fixedHeaderContainer).attr('id') + "-header-mask");
        $(fixedHeaderContainer).css("overflow", "hidden");

        // remove the viewport, not used anymore.
        var fixedHeaderViewport = $(fixedHeaderContainer).find(".afixed-table-viewport")[0];
        $(fixedHeaderViewport).remove();

        var fixedHeaderTable = $(fixedHeaderContainer).find(".afixed-table")[0];
        $(fixedHeaderTable).attr("id", $(fixedHeaderTable).attr('id') + "-header-mask");

        $(fixedHeaderTable).find('tr').each(function (rowIndex, row) {
            if ($(row).hasClass('afixed-header')) {
                isRowFixed = true;
            }
            else {
                $(row).remove();
            }
        });

        if (isRowFixed) {
            $(fixedHeaderContainer).width($(baseViewport).width());
            $(fixedHeaderContainer).css("width", $(baseViewport).css("width"));
            $(fixedHeaderContainer).height($(baseViewport).height());
            $(fixedHeaderContainer).css("height", $(baseViewport).css("height"));

            $(fixedHeaderContainer).insertAfter($(baseContainer));
            $(fixedHeaderContainer).css("zIndex", 102);
        }
        //// End : Create duplicate layer for fixed header ////

        //// Create Duplicate Layer For Fixed Column ////
        var fixedColumnContainer = $(mainContainer).find("#" + $(baseContainer).attr('id') + "-column-mask")[0];

        // remove if already exists previous column mask container.
        if (fixedColumnContainer !== undefined) {
            $(fixedColumnContainer).remove();
        }

        fixedColumnContainer = $(baseContainer).clone();

        $(fixedColumnContainer).attr("id", $(fixedColumnContainer).attr('id') + "-column-mask");
        $(fixedColumnContainer).css("overflow", "hidden");

        // remove the viewport, not used anymore.
        var fixedColumnViewport = $(fixedColumnContainer).find(".afixed-table-viewport")[0];
        $(fixedColumnViewport).remove();

        var fixedColumnTable = $(fixedColumnContainer).find(".afixed-table")[0];
        $(fixedColumnTable).attr("id", $(fixedColumnTable).attr('id') + "-column-mask");

        $(fixedColumnTable).find('tr').each(function (rowIndex, row) {
            $(row).find('th, td').each(function (columnIndex, column) {
                if ($(column).hasClass('afixed-column')) {
                    isColumnFixed = true;
                }
                else {
                    $(column).remove();
                }
            });
        });

        if (isColumnFixed) {
            $(fixedColumnContainer).width($(baseViewport).width());
            $(fixedColumnContainer).css("width", $(baseViewport).css("width"));
            $(fixedColumnContainer).height($(baseViewport).height());
            $(fixedColumnContainer).css("height", $(baseViewport).css("height"));

            $(fixedColumnContainer).insertAfter($(baseContainer));
            $(fixedColumnContainer).css("zIndex", 101);
        }
        //// End : Create Duplicate Layer For Fixed Column ////

        //// Create duplicate layer for fixed column header ////
        var fixedColumnHeaderContainer = $(mainContainer).find("#" + $(baseContainer).attr('id') + "-columnheader-mask")[0];

        // remove if already exists previous column mask container.
        if (fixedColumnHeaderContainer !== undefined) {
            $(fixedColumnHeaderContainer).remove();
        }

        fixedColumnHeaderContainer = $(baseContainer).clone();
        $(fixedColumnHeaderContainer).attr("id", $(fixedColumnHeaderContainer).attr('id') + "-columnheader-mask");
        $(fixedColumnHeaderContainer).css("overflow", "hidden");

        // remove the viewport, not used anymore.
        var fixedColumnHeaderViewport = $(fixedColumnHeaderContainer).find(".afixed-table-viewport")[0];
        $(fixedColumnHeaderViewport).remove();

        var fixedColumnHeaderTable = $(fixedColumnHeaderContainer).find(".afixed-table")[0];
        $(fixedColumnHeaderTable).attr("id", $(fixedColumnHeaderTable).attr('id') + "-columnheader-mask");

        $(fixedColumnHeaderTable).find('tr').each(function (rowIndex, row) {
            if ($(row).hasClass('afixed-header')) {
                $(row).find('th, td').each(function (columnIndex, column) {
                    if ($(column).hasClass('afixed-column')) {
                        // isRowFixed is based on fixedHeaderTable existence.
                        // isColumnFixed is base on fixedColumnTable existence.
                    }
                    else {
                        $(column).remove();
                    }
                });
            }
            else {
                $(row).remove();
            }
        });

        if (isRowFixed && isColumnFixed) {
            $(fixedColumnHeaderContainer).width($(baseViewport).width());
            $(fixedColumnHeaderContainer).css("width", $(baseViewport).css("width"));
            $(fixedColumnHeaderContainer).height($(baseViewport).height());
            $(fixedColumnHeaderContainer).css("height", $(baseViewport).css("height"));

            $(fixedColumnHeaderContainer).insertAfter($(baseContainer));
            $(fixedColumnHeaderContainer).css("zIndex", 103);
        }
        //// End : Create duplicate layer for fixed column header ////

        //// Funciton Handle Base Container Scrolling ////
        $(baseContainer).on("scroll", function () {
            var scrollLeft = $(baseContainer).scrollLeft();
            var scrollTop = $(baseContainer).scrollTop();

            $(fixedHeaderTable).css("margin-left", -scrollLeft);
            $(fixedColumnTable).css("margin-top", -scrollTop);

            $(fixedColumnHeaderTable).css("margin-left", 0);
            $(fixedColumnHeaderTable).css("margin-top", 0);
        });
        //// End : Funciton Handle Base Container Scrolling ////
    }
};
$.resetFixedTable = function () {
    var mainContainer = document.getElementsByClassName("afixed-main-container")[0];
    if (mainContainer !== undefined) {
        var baseViewport = $(mainContainer).find(".afixed-table-viewport")[0];
        var baseContainer = $(mainContainer).find(".afixed-table-container")[0];

        $.resizeFixedTable(mainContainer, baseViewport);
        $.relocateFixedTable(mainContainer, baseContainer);
    }
};
var fixedContainerWidth = 0;
var fixedContainerHeight = 0;
var fixedHeaderContainerWidth = 0;
var fixedHeaderContainerHeight = 0;
$.resizeFixedTable = function () {
    var mainContainer = document.getElementsByClassName("afixed-main-container")[0];
    if (mainContainer !== undefined) {
        var baseViewport = $(mainContainer).find(".afixed-table-viewport")[0];
        var baseTable = $(mainContainer).find(".afixed-table")[0];

        $.setBaseTableWidth(baseTable, baseViewport);

        //// Fixed Header Resizing ////
        var fixedHeaderContainer = $(mainContainer).find("div[id$='-header-mask']");
        var fixedHeaderTable = $(fixedHeaderContainer).find("table[id$='-header-mask']");

        fixedHeaderContainerHeight = 0;
        $(fixedHeaderTable).find('tr').each(function (rowIndex, row) {
            fixedHeaderContainerWidth = 0;
            if ($(row).hasClass('afixed-header')) {
                var baseHeader = $(baseTable).find("[id='" + $(row).attr('id') + "']");

                var baseHeaderHeight = 0;
                baseHeaderHeight = $(baseHeader).height();
                $(row).height(baseHeaderHeight);

                fixedHeaderContainerHeight = fixedHeaderContainerHeight + $(baseHeader).height();

                baseHeaderHeight = $(baseHeader).css("height");
                $(row).css("height", baseHeaderHeight);

                var baseHeaderWidth = 0;
                baseHeaderWidth = $(baseHeader).width();
                $(row).width(baseHeaderWidth);
                baseHeaderWidth = $(baseHeader).css("width");
                $(row).css("width", baseHeaderWidth);

                fixedHeaderContainerWidth = fixedHeaderContainerWidth + $(baseHeader).outerWidth(true);
            }
        });

        $(fixedHeaderTable).css("width", fixedHeaderContainerWidth + "px");

        $(fixedHeaderContainer).width(fixedHeaderContainerWidth);
        $(fixedHeaderContainer).css("width", fixedHeaderContainerWidth + "px");
        if ($(fixedHeaderContainer).width() >= $(baseViewport).width()) {
            $(fixedHeaderContainer).width($(baseViewport).width());
            $(fixedHeaderContainer).css("width", $(baseViewport).css("width"));
        }

        $(fixedHeaderTable).css("height", fixedHeaderContainerHeight + "px");

        $(fixedHeaderContainer).height(fixedHeaderContainerHeight);
        $(fixedHeaderContainer).css("height", fixedHeaderContainerHeight + "px");
        if ($(fixedHeaderContainer).height() >= $(baseViewport).height()) {
            $(fixedHeaderContainer).height($(baseViewport).height());
            $(fixedHeaderContainer).css("height", $(baseViewport).css("height"));
        }
        //// End : Fixed Header Resizing ////

        //// Fixed Column Resizing ////
        var fixedColumnContainer = $(mainContainer).find("div[id$='-column-mask']");
        var fixedColumnTable = $(fixedColumnContainer).find("table[id$='-column-mask']");

        $(fixedColumnTable).find('tr').each(function (rowIndex, row) {
            $(row).find('th, td').each(function (columnIndex, column) {
                var baseColumn = $(baseTable).find("[id='" + $(column).attr('id') + "']");

                var baseColumnHeight = 0;
                baseColumnHeight = $(baseColumn).height();
                $(column).height(baseColumnHeight);
                baseColumnHeight = $(baseColumn).css("height");
                $(column).css("height", baseColumnHeight);

                var baseColumnWidth = 0;
                baseColumnWidth = $(baseColumn).width();
                $(column).width(baseColumnWidth);
                baseColumnWidth = $(baseColumn).css("width");
                $(column).css("width", baseColumnWidth);
            });
        });

        fixedContainerWidth = 0;
        $(fixedColumnTable).find("tr:first-child").find("th, th[rowspan], th[colspan]").each(function (columnIndex, column) {
            var baseColumn = $(baseTable).find("[id='" + $(column).attr('id') + "']");
            fixedContainerWidth = fixedContainerWidth + $(baseColumn).outerWidth(true);
        });
        $(fixedColumnTable).css("width", fixedContainerWidth + "px");

        $(fixedColumnContainer).width(fixedContainerWidth);
        $(fixedColumnContainer).css("width", fixedContainerWidth + "px");
        if ($(fixedColumnContainer).width() >= $(baseViewport).width()) {
            $(fixedColumnContainer).width($(baseViewport).width());
            $(fixedColumnContainer).css("width", $(baseViewport).css("width"));
        }

        $(fixedColumnTable).css("height", fixedHeaderContainerHeight + "px");

        $(fixedColumnContainer).height($(baseViewport).height());
        $(fixedColumnContainer).css("height", $(baseViewport).css("height"));

        //$(fixedColumnContainer).height(fixedHeaderContainerHeight);
        //$(fixedColumnContainer).css("height", fixedHeaderContainerHeight + "px");
        //if ($(fixedColumnContainer).height() >= $(baseViewport).height()) {
        //    $(fixedColumnContainer).height($(baseViewport).height());
        //    $(fixedColumnContainer).css("height", $(baseViewport).css("height"));
        //}
        //// End : Fixed Column Resizing ////

        //// Fixed Column Header Resizing ////
        var fixedColumnHeaderContainer = $(mainContainer).find("div[id$='-columnheader-mask']");
        var fixedColumnHeaderTable = $(fixedColumnHeaderContainer).find("table[id$='-columnheader-mask']");

        $(fixedColumnHeaderTable).find('tr').each(function (rowIndex, row) {
            if ($(row).hasClass('afixed-header')) {
                $(row).find('th').each(function (columnIndex, column) {
                    if ($(column).hasClass('afixed-column')) {
                        var baseColumn = $(baseTable).find("[id='" + $(column).attr('id') + "']");

                        var baseHeadHeight = 0;
                        baseHeadHeight = $(baseColumn).height();
                        $(row).height(baseHeadHeight);
                        baseHeadHeight = $(baseColumn).css("height");
                        $(row).css("height", baseHeadHeight);

                        var baseColumnWidth = 0;
                        baseColumnWidth = $(baseColumn).width();
                        $(column).width(baseColumnWidth);
                        baseColumnWidth = $(baseColumn).css("width");
                        $(column).css("width", baseColumnWidth);
                    }
                });
            }
        });

        $(fixedColumnHeaderTable).css("width", fixedContainerWidth + "px");

        $(fixedColumnHeaderContainer).width(fixedContainerWidth);
        $(fixedColumnHeaderContainer).css("width", fixedContainerWidth + "px");
        if ($(fixedColumnHeaderContainer).width() >= $(baseViewport).width()) {
            $(fixedColumnHeaderContainer).width($(baseViewport).width());
            $(fixedColumnHeaderContainer).css("width", $(baseViewport).css("width"));
        }

        $(fixedColumnHeaderTable).css("height", fixedHeaderContainerHeight + "px");

        $(fixedColumnHeaderContainer).height(fixedHeaderContainerHeight);
        $(fixedColumnHeaderContainer).css("height", fixedHeaderContainerHeight + "px");
        if ($(fixedColumnHeaderContainer).height() >= $(baseViewport).height()) {
            $(fixedColumnHeaderContainer).height($(baseViewport).height());
            $(fixedColumnHeaderContainer).css("height", $(baseViewport).css("height"));
        }
        //// End : Fixed Column Header Resizing ////

    }
};
$.relocateFixedTable = function (mainContainer, baseContainer) {
    var fixedHeaderTable = $(mainContainer).find("table[id$='-header-mask']");
    var fixedColumnTable = $(mainContainer).find("table[id$='-column-mask']");
    var fixedColumnHeaderTable = $(mainContainer).find("table[id$='-columnheader-mask']");

    //// Relocate The Fixed Table Mask ////
    var scrollLeft = $(baseContainer).scrollLeft();
    var scrollTop = $(baseContainer).scrollTop();

    $(fixedHeaderTable).css("margin-left", -scrollLeft);
    $(fixedColumnTable).css("margin-top", -scrollTop);

    $(fixedColumnHeaderTable).css("margin-left", 0);
    $(fixedColumnHeaderTable).css("margin-top", 0);
    //// End : Relocate The Fixed Table Mask ////
};

$(document).init(function () {
    $.initFixedTable();
});
$(document).ready(function () {
    $.resetFixedTable();
});
$(window).resize(function () {
    $.remakeFixedTable();
});


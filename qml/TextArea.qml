/**
 * Copyright (C) Olivier Le Doeuff 2019
 * Contact: olivier.ldff@gmail.com
 */

import QtQuick 2.12
import QtQuick.Controls 2.12

import Qaterial 1.0

Control
{
    id: control

    signal editingFinished()
    signal linkActivated(string link)
    signal linkHovered(string link)

    // TEXT AREA ALIAS
    property string placeholderText
    property string text
    property int wrapMode: Text.Wrap
    property bool cursorVisible: true

    // CONTENT
    property string title
    property string helperText
    property string prefixText
    property string suffixText
    property url leadingIconSource

    // COLORS
    property color color: enabled ? Style.primaryTextColor() : Style.hintTextColor()
    property color selectionColor: Style.accentColor
    property color selectedTextColor: Style.shouldReverseForegroundOnAccent ? Style.primaryTextColorReversed() : Style.primaryTextColor()
    property color placeholderTextColor: Style.hintTextColor()

    property color titleTextColor: enabled ? (errorState && titleUp ? Style.errorColor : Style.hintTextColor()) : Style.dividersColor()
    property color helperTextColor: enabled ? (errorState ? Style.errorColor : Style.hintTextColor()) : Style.dividersColor()
    property color prefixTextColor: enabled ? (Style.hintTextColor()) : Style.dividersColor()
    property color suffixTextColor: enabled ? (Style.hintTextColor()) : Style.dividersColor()
    property color leadingIconColor: enabled ? (textAreaActiveFocus ? Style.accentColor : Style.secondaryTextColor()) : Style.disabledTextColor()

    // LOOK
    property int verticalAlignment: TextInput.AlignTop
    property int renderType: Text.QtRendering
    property bool leadingIconInline: false
    property bool leadingIconVisible: leadingIconSource != ""
    property bool leadingIconErrorAnimation: false
    property bool trailingInline: true

    property int textType: Style.TextType.ListText
    property int titleTextType: titleUp ? Style.TextType.Caption : textType
    property int placeholderTextType: textType
    property int prefixTextType: textType
    property int suffixTextType: textType
    property int hintTextType: Style.TextType.Hint

    property bool titleUp: textAreaActiveFocus || control.length || control.preeditText
    readonly property bool anyHintVisible: (control.helperText != "" || control._errorText != "") || _lineCountLabel.visible

    property bool onPrimary: false
    property bool colorReversed: onPrimary && Style.shouldReverseForegroundOnPrimary

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    topPadding: 0//control.title != "" ? Style.textField.topPaddingTitle : Style.textField.topPadding
    bottomPadding: 0//anyHintVisible ? Style.textField.bottomPaddingHint : Style.textField.bottomPadding

    property double virtualLeftPadding: ((leadingIconVisible) ? _leadingIcon.width + leadingSpacing : 0) + ((leadingIconVisible && !leadingIconInline) ?Style.textField.horizontalPadding : 0)

    property double virtualRightPadding: ((trailingVisible) ? _trailingContent.width + trailingSpacing : 0) + ((trailingVisible && !trailingInline) ?Style.textField.horizontalPadding : 0)

    leftPadding: 0//virtualLeftPadding + (prefixText != "" ? _prefixLabel.contentWidth + textSpacing : 0)
    rightPadding: virtualRightPadding + (suffixText != "" ? _suffixLabel.contentWidth + textSpacing : 0)
    property double leadingSpacing: Style.textField.leadingSpacing
    property double textSpacing: Style.textField.textSpacing
    property double trailingSpacing: 0

    leftInset: (!leadingIconInline && leadingIconVisible) ? _leadingIcon.width + leadingSpacing : 0
    rightInset: (!trailingInline && trailingVisible) ? _trailingContent.width + trailingSpacing : 0

    // DEBUG
    property bool drawline: Style.debug.drawDebugButton
    DebugRectangle
    {
        anchors.fill: parent
        border.color: "blue"
        visible: control.drawline
    }

    // LEADING ICON
    ColorIcon
    {
        id: _leadingIcon
        color: control.leadingIconColor
        source: control.leadingIconSource
        iconSize: Style.textField.iconSize
        width: Style.textField.iconWidth
        height: Style.textField.iconWidth
        y: Style.textField.topPadding

        opacity: control.leadingIconVisible ? color.a : 0.0
        Behavior on opacity { NumberAnimation { easing.type: Easing.OutCubic; duration: 200 } }
    }

    // trailing ICON
    property alias trailingContent: _trailingContent.sourceComponent
    property bool trailingVisible: _trailingContent.sourceComponent != undefined
    Loader
    {
        id: _trailingContent
        y: Style.textField.topPadding
        x: control.width - width
        opacity: control.trailingVisible ? color.a : 0.0
        onSourceComponentChanged:
        {
            if(item && ((typeof item.textArea) == "object"))
            {
                item.textArea = control
            }
        }
        Behavior on opacity { NumberAnimation { easing.type: Easing.OutCubic; duration: 200 } }
    }

    // TITLE
    Label
    {
        id: _titleLabel
        visible: control.title != ""
        text: control.title
        DebugRectangle
        {
            anchors.fill: parent
            border.color: "violet"
            visible: control.drawline
        } // DebugRectangle
        textType: control.titleTextType
        color: control.titleTextColor
        x: textAreaLeftPadding
        y: titleUp ? Style.textField.topPaddingTitleOffset : textAreaTopPadding
        width: control.width - textAreaLeftPadding - control.rightPadding
        verticalAlignment: control.verticalAlignment
        renderType: control.renderType
        elide: Text.ElideRight
        Behavior on y
        {
            NumberAnimation { easing.type:Easing.OutCubic; duration: 200 }
        } // Behavior y
        font.pixelSize: Style.textTypeToPixelSize(textType)
        Behavior on font.pixelSize
        {
            NumberAnimation { easing.type:Easing.OutCubic; duration: 200 }
        } // Behavior pixelsize
        Behavior on color
        {
            ColorAnimation { easing.type:Easing.OutCubic; duration: 200 }
        } // Behavior color
    } // Title Label

    // HELPER TEXT
    property bool errorState: _errorText != ""
    property bool acceptableInput: true
    property int length: textArea.length
    property bool textAreaActiveFocus: textArea.activeFocus
    property string preeditText: textArea.preeditText
    property string _errorText: ""
    property string errorText: helperText
    property bool autoSubmit: true
    property bool editedAtLeastOnce: false
    property bool error: (!acceptableInput || (length > maximumLengthCount))
    onErrorChanged: if((editedAtLeastOnce || length) && autoSubmit) Qt.callLater(submitInput)
    onEditingFinished:
    {
        editedAtLeastOnce = true
        if(autoSubmit)
            Qt.callLater(submitInput)
    }
    ErrorSequentialAnimation { id: _errorAnimation; target: _titleLabel; x: textAreaLeftPadding }
    ErrorSequentialAnimation { id: _errorLeadingAnimation; target: _leadingIcon; x: control.width - _leadingIcon.width }

    function submitInput()
    {
        if(!error)
            clearError()
        else
            setError(errorText)
    }
    function clearError()
    {
        if(errorState)
            _errorText = ""
    }
    function setError(s)
    {
        if(!errorState)
        {
            if(titleUp)
                _errorAnimation.start()
            if(leadingIconErrorAnimation)
                 _errorLeadingAnimation.start()
            _errorText = s
        }
    }
    Label // Hint
    {
        opacity: (control.helperText != "" || control._errorText != "") ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { easing.type:Easing.OutCubic; duration: 100 } }
        text: control.errorState ? control._errorText : control.helperText
        DebugRectangle
        {
            anchors.fill: parent
            border.color: "violet"
            visible: control.drawline
        } // DebugRectangle
        textType: control.hintTextType
        color: control.helperTextColor
        width: control.width - textAreaLeftPadding - control.rightPadding - _lineCountLabel.width
        x: textAreaLeftPadding
        y: control.height - height - Style.textField.bottomPaddingHintOffset
        verticalAlignment: control.verticalAlignment
        renderType: control.renderType
        elide: Text.ElideRight
    } // Hint Label

    property int maximumLengthCount: 32767

    Label // LineCounter
    {
        id: _lineCountLabel
        visible: control.maximumLengthCount > 0 && control.maximumLengthCount < 32767
        text: control.length + "/" + control.maximumLengthCount
        DebugRectangle
        {
            anchors.fill: parent
            border.color: "violet"
            visible: control.drawline
        } // DebugRectangle
        textType: control.hintTextType
        color: control.helperTextColor
        x: control.width - width - (control.trailingInline ? 0 : control.rightPadding)
        y: control.height - height - Style.textField.bottomPaddingHintOffset
        verticalAlignment: control.verticalAlignment
        renderType: control.renderType
    } // LineCounter

    Label // Prefix Label
    {
        id: _prefixLabel
        DebugRectangle
        {
            anchors.fill: parent
            border.color: "violet"
            visible: control.drawline
        } // DebugRectangle
        height: control.contentHeight
        x: textAreaLeftPadding
        y: control.topPadding
        text: control.prefixText
        color: control.prefixTextColor
        textType: control.prefixTextType
        verticalAlignment: control.verticalAlignment
        renderType: control.renderType
        opacity: (control.prefixText != "" && textAreaActiveFocus || control.length) ? 1.0 : 0.0

        Behavior on opacity { NumberAnimation { easing.type: Easing.OutCubic; duration: 200 } }
    } // Prefix

    Label // Suffix Label
    {
        id: _suffixLabel
        DebugRectangle
        {
            anchors.fill: parent
            border.color: "violet"
            visible: control.drawline
        } // DebugRectangle
        height: control.contentHeight
        x: control.width - width - control.rightPadding
        y: control.topPadding
        textType: control.suffixTextType
        text: control.suffixText
        color: control.suffixTextColor
        verticalAlignment: control.verticalAlignment
        renderType: control.renderType
        opacity: (control.suffixText != "" && textAreaActiveFocus || control.length) ? 1.0 : 0.0

        Behavior on opacity { NumberAnimation { easing.type: Easing.OutCubic; duration: 200 } }
    } // Suffix

    Behavior on bottomPadding { NumberAnimation { easing.type:Easing.OutCubic; duration: 200 } }

    property var textArea: _textArea

    property double textAreaRightPadding    : 0
    property double textAreaLeftPadding     : control.virtualLeftPadding + (control.prefixText != "" ? _prefixLabel.contentWidth + control.textSpacing : 0)
    property double textAreaTopPadding      : control.title != "" ? Style.textField.topPaddingTitle : Style.textField.topPadding
    property double textAreaBottomPadding   : control.anyHintVisible ? Style.textField.bottomPaddingHint : Style.textField.bottomPadding

    contentItem: TextAreaContent
    {
        id: _textArea
        onPrimary: control.onPrimary
        colorReversed: control.colorReversed
        topPadding:  control.title != "" ? Style.textField.topPaddingTitle : Style.textField.topPadding
        bottomPadding: control.anyHintVisible ? Style.textField.bottomPaddingHint : Style.textField.bottomPadding

        leftPadding: control.virtualLeftPadding + (control.prefixText != "" ? _prefixLabel.contentWidth + control.textSpacing : 0)

        onEditingFinished: control.editingFinished()
        onLinkActivated: control.linkActivated(link)
        onLinkHovered: control.linkHovered(link)

        forcePlaceholderOff: !control.titleUp
        textType: control.textType
        placeholderText: control.placeholderText
        text: control.text
        wrapMode: control.wrapMode
        cursorVisible: control.cursorVisible
        color: control.color
        selectionColor: control.selectionColor
        selectedTextColor: control.selectedTextColor
        placeholderTextColor: control.placeholderTextColor
        verticalAlignment: control.verticalAlignment
        renderType: control.renderType
    } // TextAreaContent

    // BACKGROUND
    property double backgroundBorderHeight: Style.textField.backgroundBorderHeight
    property color backgroundColor: errorState ? Style.errorColor : Style.hintTextColor()
    property color backgroundHighlightColor: errorState ? Style.errorColor : Style.accentColor
    background: Rectangle
    {
        y: control.height - height - textAreaBottomPadding + 8
        implicitWidth: Style.textField.implicitWidth
        width: parent.width
        height: textAreaActiveFocus || control.hovered ? control.backgroundBorderHeight : 1
        color: control.backgroundColor

        DebugRectangle
        {
            anchors.fill: parent
            border.color: "blue"
            visible: control.drawline
        } // DebugRectangle

        Rectangle
        {
            height: control.backgroundBorderHeight
            color:  control.backgroundHighlightColor
            width:  textAreaActiveFocus ? parent.width : 0
            x:      textAreaActiveFocus ? 0 : parent.width/2

            Behavior on width
            {
                enabled: !textAreaActiveFocus
                NumberAnimation { easing.type:Easing.OutCubic; duration: 300 }
            } // Behavior

            Behavior on x
            {
                enabled: !textAreaActiveFocus
                NumberAnimation { easing.type:Easing.OutCubic; duration: 300 }
            } // Behavior

            DebugRectangle
            {
                anchors.fill: parent
                border.color: "red"
                visible: control.drawline
            } // DebugRectangle
        } // Rectangle
    } // Rectangle
} // Controls

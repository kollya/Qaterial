/**
 * Copyright (C) Olivier Le Doeuff 2019
 * Contact: olivier.ldff@gmail.com
 */

import QtQuick 2.12
import QtQuick.Templates 2.12 as T
import QtQuick.Controls 2.12

import Qaterial 1.0

/**
 * CONTENT
 * - text
 * - title
 * - helperText
 * - placeholderText
 * - prefixText
 * - suffixText
 *
 * - leadingIconSource
 * - leadingSpacing
 * - leadingVisible
 *
 * - trailingContent
 * - tralingVisible
 * - tralingSpacing
 *
 * COLOR
 *
 * - color / textColor
 * - titleTextColor
 * - helperTextColor
 * - prefixTextColor
 * - suffixTextColor
 * - leadingIconColor
 * - trailingIconColor
 *
 * BEHAVIOR
 *
 * LOOK
 * - echoMode (TextInput.Normal | Password  | NoEcho | PasswordEchoOnEdit )
 * - leadingIconInline
 * - trailingIconInline
 *
 * DOC
 * https://doc.qt.io/qt-5/qml-qtquick-textinput.html
 * https://doc.qt.io/qt-5/qml-qtquick-controls2-textfield.html
 */
T.TextField
{
    id: control

    // CONTENT
    property string title
    property string helperText
    property string prefixText
    property string suffixText
    property url leadingIconSource

    // LOOK
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

    property bool titleUp: control.activeFocus || control.length || control.preeditText
    readonly property bool anyHintVisible: (control.helperText != "" || control._errorText != "") || _lineCountLabel.visible

    property bool onPrimary: false
    property bool colorReversed: onPrimary && Style.shouldReverseForegroundOnPrimary

    font.family: Style.textTypeToFontFamily(textType)
    font.styleName: Style.textTypeToStyleName(textType)
    font.pixelSize: Style.textTypeToPixelSize(textType)
    font.capitalization: Style.fontCapitalization(textType)
    font.letterSpacing: Style.textTypeToLetterSpacing(textType)

    // DEBUG
    property bool drawline: Style.debug.drawDebugButton
    DebugRectangle
    {
        anchors.fill: parent
        border.color: "pink"
        visible: control.drawline
    }
    DebugRectangle
    {
        x: control.leftPadding
        y: control.topPadding
        width: control.width - control.leftPadding - control.rightPadding
        height: control.contentHeight
        border.color: "orange"
        visible: control.drawline
    }
    DebugRectangle
    {
        x: control.leftPadding
        y: control.topPadding
        width: Math.min(control.contentWidth, control.width - control.leftPadding - control.rightPadding)
        height: control.contentHeight
        border.color: "red"
        visible: control.drawline
    }

    // SIZE
    implicitWidth: implicitBackgroundWidth + leftInset + rightInset
                   || Math.max(contentWidth, placeholder.implicitWidth) + control.virtualLeftPadding + control.virtualRightPadding
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             contentHeight + topPadding + bottomPadding,
                             placeholder.implicitHeight + topPadding + bottomPadding)

    topPadding: control.title != "" ? Style.textField.topPaddingTitle : Style.textField.topPadding
    bottomPadding: anyHintVisible ? Style.textField.bottomPaddingHint : Style.textField.bottomPadding

    property double virtualLeftPadding: ((leadingIconVisible) ? _leadingIcon.width + leadingSpacing : 0) + ((leadingIconVisible && !leadingIconInline) ?Style.textField.horizontalPadding : 0)

    property double virtualRightPadding: ((trailingVisible) ? _trailingContent.width + trailingSpacing : 0) + ((trailingVisible && !trailingInline) ?Style.textField.horizontalPadding : 0)

    leftPadding: virtualLeftPadding + (prefixText != "" ? _prefixLabel.contentWidth + textSpacing : 0)
    rightPadding: virtualRightPadding + (suffixText != "" ? _suffixLabel.contentWidth + textSpacing : 0)
    property double leadingSpacing: Style.textField.leadingSpacing
    property double textSpacing: Style.textField.textSpacing
    property double trailingSpacing: 0

    leftInset: (!leadingIconInline && leadingIconVisible) ? _leadingIcon.width + leadingSpacing : 0
    rightInset: (!trailingInline && trailingVisible) ? _trailingContent.width + trailingSpacing : 0

    Behavior on bottomPadding { NumberAnimation { easing.type:Easing.OutCubic; duration: 200 } }

    // COLORS
    property alias textColor: control.color
    color: enabled ? Style.primaryTextColor() : Style.hintTextColor()
    selectionColor: Style.accentColor
    selectedTextColor: Style.shouldReverseForegroundOnAccent ? Style.primaryTextColorReversed() : Style.primaryTextColor()
    placeholderTextColor: Style.hintTextColor()
    verticalAlignment: TextInput.AlignVCenter

    property color titleTextColor: enabled ? (errorState && titleUp ? Style.errorColor : Style.hintTextColor()) : Style.dividersColor()
    property color helperTextColor: enabled ? (errorState ? Style.errorColor : Style.hintTextColor()) : Style.dividersColor()
    property color prefixTextColor: enabled ? (Style.hintTextColor()) : Style.dividersColor()
    property color suffixTextColor: enabled ? (Style.hintTextColor()) : Style.dividersColor()
    property color leadingIconColor: enabled ? (activeFocus ? Style.accentColor : Style.secondaryTextColor()) : Style.disabledTextColor()

    // BEHAVIOR
    selectByMouse: true

    // CURSOR
    cursorDelegate: CursorDelegate { }

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
        y: control.title != "" ? Style.textField.topPadding : 0
        x: control.width - width
        opacity: control.trailingVisible ? color.a : 0.0
        onSourceComponentChanged:
        {
            if(item && ((typeof item.textField) == "object"))
            {
                item.textField = control
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
        x: control.virtualLeftPadding
        y: titleUp ? Style.textField.topPaddingTitleOffset : control.topPadding
        width: control.width - control.virtualLeftPadding - control.virtualRightPadding
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
    property string _errorText: ""
    property string errorText: helperText
    property bool autoSubmit: true
    property bool editedAtLeastOnce: false
    property bool error: (!acceptableInput || (length > maximumLengthCount))
    onErrorChanged: if(editedAtLeastOnce && autoSubmit) Qt.callLater(submitInput)
    onTextEdited:
    {
        editedAtLeastOnce = true
        if(autoSubmit)
            Qt.callLater(submitInput)
    }
    ErrorSequentialAnimation { id: _errorAnimation; target: _titleLabel; x: control.virtualLeftPadding }
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
            _errorText = s ? s : " "
            if(!s)
                console.log("Error: No Error text provided, please provide errorText property to guide your user")
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
        width: control.width - control.virtualLeftPadding - control.virtualRightPadding - _lineCountLabel.width
        x: control.virtualLeftPadding
        y: control.height - height - Style.textField.bottomPaddingHintOffset
        verticalAlignment: control.verticalAlignment
        renderType: control.renderType
        elide: Text.ElideRight
    } // Hint Label

    property int maximumLengthCount: maximumLength

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
        x: control.width - width - (control.trailingInline ? 0 : control.virtualRightPadding)
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
        x: control.virtualLeftPadding
        y: control.topPadding
        text: control.prefixText
        color: control.prefixTextColor
        textType: control.prefixTextType
        verticalAlignment: control.verticalAlignment
        renderType: control.renderType
        opacity: (control.prefixText != "" && control.activeFocus || control.length) ? 1.0 : 0.0

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
        x: control.width - width - control.virtualRightPadding
        y: control.topPadding
        textType: control.suffixTextType
        text: control.suffixText
        color: control.suffixTextColor
        verticalAlignment: control.verticalAlignment
        renderType: control.renderType
        opacity: (control.suffixText != "" && control.activeFocus || control.length) ? 1.0 : 0.0

        Behavior on opacity { NumberAnimation { easing.type: Easing.OutCubic; duration: 200 } }
    } // Suffix

    // PLACEHOLDER
    PlaceholderText
    {
        id: placeholder
        x: control.leftPadding
        y: control.topPadding
        width: control.width - (control.leftPadding + control.rightPadding)
        height: control.height - (control.topPadding + control.bottomPadding)
        text: control.placeholderText
        color: control.placeholderTextColor
        textType: control.placeholderTextType
        verticalAlignment: control.verticalAlignment
        elide: Text.ElideRight
        renderType: control.renderType
        readonly property bool shouldBeVisible: (control.title == "" || control.activeFocus) && !control.length && !control.preeditText && (!control.activeFocus || control.horizontalAlignment !== Qt.AlignHCenter)
        opacity: shouldBeVisible ? 1.0 : 0.0

        Behavior on opacity
        {
            NumberAnimation { easing.type: Easing.InQuad; duration: placeholder.shouldBeVisible ? 50 : 200 }
        }
    } // PlaceholderText

    // BACKGROUND
    property double backgroundBorderHeight: Style.textField.backgroundBorderHeight
    property color backgroundColor: errorState ? Style.errorColor : Style.hintTextColor()
    property color backgroundHighlightColor: errorState ? Style.errorColor : Style.accentColor
    background: Rectangle
    {
        y: control.height - height - control.bottomPadding + 8
        implicitWidth: Style.textField.implicitWidth
        width: parent.width
        height: control.activeFocus || control.hovered ? control.backgroundBorderHeight : 1
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
            width:  control.activeFocus ? parent.width : 0
            x:      control.activeFocus ? 0 : parent.width/2

            Behavior on width
            {
                enabled: !control.activeFocus
                NumberAnimation { easing.type:Easing.OutCubic; duration: 300 }
            } // Behavior

            Behavior on x
            {
                enabled: !control.activeFocus
                NumberAnimation { easing.type:Easing.OutCubic; duration: 300 }
            } // Behavior

            DebugRectangle
            {
                anchors.fill: parent
                border.color: "red"
                visible: control.drawline
            } // DebugRectangle
        }
    } // Rectangle
} // TextField

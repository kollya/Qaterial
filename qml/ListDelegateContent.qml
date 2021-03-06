/**
 * Copyright (C) Olivier Le Doeuff 2019
 * Contact: olivier.ldff@gmail.com
 */

// Qt
import QtQuick 2.12

import QtGraphicalEffects 1.12

// Qaterial
import Qaterial 1.0

Rectangle
{
    id: control

    // TEXT
    property alias text: _text.text
    property alias overlineText: _text.overlineText
    property alias secondaryText: _text.secondaryText

    // THUMBNAIL
    property string roundSource
    property string squareSource
    property string largeSource

    readonly property bool roundSourceSet: roundSource != ""
    readonly property bool squareSourceSet: squareSource != ""
    readonly property bool largeSourceSet: largeSource != ""

    property bool largeThumbnail: false

    // ICON
    property alias roundIcon: _icon.roundIcon
    property alias roundColor: _icon.roundColor
    property alias fillIcon: _icon.fill
    property alias outlinedIcon: _icon.outlined
    property alias highlightedIcon: _icon.highlighted
    property alias reverseHighlightIcon: _icon.reverseHighlight
    property alias iconSource: _icon.source
    property alias iconWidth: _icon.width
    property alias iconHeight: _icon.height
    property alias iconColor: _icon.color

    // ALIGNMENT
    property bool alignTextRight: false
    property bool drawline: false
    property bool enabled: true
    property bool mirrored: false
    property double spacing: 0

    property double padding
    property double leftPadding: padding
    property double rightPadding: padding
    property double topPadding: padding
    property double bottomPadding: padding

    property bool onPrimary: false
    property bool colorReversed: onPrimary && Style.shouldReverseForegroundOnPrimary

    readonly property alias lines: _text.lines

    // Style.DelegateType.Default | Style.DelegateType.Overline | Style.DelegateType.Icon
    // Style.DelegateType.Round | Style.DelegateType.Square | Style.DelegateType.Large
    readonly property int type: (icon.source != "") ? (roundIcon ? Style.DelegateType.RoundIcon : Style.DelegateType.Icon) :
        overlineText != "" ? Style.DelegateType.Overline :
        (roundSourceSet || squareSourceSet) ? (largeThumbnail ? Style.DelegateType.Square : Style.DelegateType.Round) :
        largeSourceSet ? Style.DelegateType.Large : Style.DelegateType.Default

    property alias imageSourceSize: _image.sourceSize

    color: "transparent"
    implicitWidth: _icon.implicitWidth
    implicitHeight:  _text.implicitHeight

    function reanchors()
    {
        _icon.reanchors()
        _virtualImage.reanchors()
    }

    onMirroredChanged: reanchors()
    onTypeChanged: reanchors()
    Component.onCompleted: reanchors()

    RoundColorIcon
    {
        id: _icon
        visible: source != ""
        iconSize: Style.delegate.iconWidth
        highlighted: true
        enabled: control.enabled

        fill: true
        width: roundIcon ? roundSize : iconSize
        height: roundIcon ? roundSize : iconSize

        anchors.top: control.top
        anchors.topMargin: Style.delegate.topPadding(control.type, control.lines)
        anchors.left: control.left

        function reanchors()
        {
            anchors.left = undefined
            anchors.right = undefined
            if(mirrored)
                anchors.right = control.right
            else
                anchors.left = control.left
        }

        DebugRectangle
        {
            anchors.fill: parent
            border.color: "orange"
            visible: control.drawline
        }
    } // ColorIcon

    Item
    {
        id: _virtualImage
        enabled: control.enabled
        visible: control.roundSourceSet || control.squareSourceSet || control.largeSourceSet
        width: control.roundSourceSet ? Style.delegate.roundWidth(control.largeThumbnail) :
            control.squareSourceSet ? Style.delegate.squareWidth(control.largeThumbnail) :
            control.largeSourceSet ? Style.delegate.largeWidth() : 0
        height: control.roundSourceSet ? Style.delegate.roundWidth(control.largeThumbnail) :
            control.squareSourceSet ? Style.delegate.squareWidth(control.largeThumbnail) :
            control.largeSourceSet ? Style.delegate.largeHeight() : 0

        anchors.top: control.top
        anchors.topMargin: Style.delegate.topPadding(control.type, control.lines)
        anchors.left: control.left

        function reanchors()
        {
            anchors.left = undefined
            anchors.right = undefined
            if(mirrored)
                anchors.right = control.right
            else
                anchors.left = control.left
        }

        Image
        {
            id: _image
            fillMode: Image.PreserveAspectCrop
            width: parent.width
            height: parent.height
            anchors.centerIn: parent
            source: control.roundSourceSet ? control.roundSource :
                control.squareSourceSet ? control.squareSource :
                control.largeSource

            sourceSize.width: width
            sourceSize.height: height

            layer.enabled: control.roundSourceSet
            layer.effect: OpacityMask
            {
                maskSource: Rectangle
                {
                    width: _image.width
                    height: _image.height
                    radius: _image.width/2
                }
            } // OpacityMask
        }

        DebugRectangle
        {
            anchors.fill: parent
            border.color: "orange"
            visible: control.drawline
        }
    }

    ListDelegateText
    {
        id: _text
        enabled: control.enabled
        alignTextRight: control.alignTextRight
        type: control.type
        drawline: control.drawline
        onPrimary: control.onPrimary
        colorReversed: control.colorReversed
        anchors.top: control.top
        anchors.bottom: control.bottom
        anchors.left: mirrored ? control.left : (_icon.source != "" ? _icon.right : _image.source != "" ? _virtualImage.right : control.left)
        anchors.right: mirrored ? (_icon.source != "" ? _icon.left : _image.source != "" ? _virtualImage.left : control.right) : control.right
        anchors.leftMargin: !mirrored ? control.spacing : control.leftPadding
        anchors.rightMargin: mirrored ? control.spacing : control.rightPadding
        mirrored: control.mirrored
    }

    DebugRectangle
    {
        anchors.fill: parent
        border.color: "red"
        visible: control.drawline
    } // DebugRectangle
} // Rectangle

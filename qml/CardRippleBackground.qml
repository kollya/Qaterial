/**
 * Copyright (C) Olivier Le Doeuff 2019
 * Contact: olivier.ldff@gmail.com
 */

// Qt
import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.12

// Qaterial
import Qaterial 1.0

CardBackground
{
    id: control

    property alias pressed: _ripple.pressed
    property alias rippleActive: _ripple.active
    property alias rippleColor: _ripple.color
    property alias rippleAnchor: _ripple.anchor
    property alias enabled: _ripple.enabled
    Ripple
    {
        id: _ripple
        width: parent.width - parent.border.width*2
        height: parent.height - parent.border.width*2
        x: parent.border.width
        y: parent.border.width

        clip: visible
        color: Style.rippleColor(parent.onPrimary ? Style.RippleBackground.Primary : Style.RippleBackground.Background)

        // trick because clipRadius isn't working in ripple private implementation (QTBUG-51894)
        layer.enabled: true
        layer.effect: OpacityMask
        {
            maskSource: Rectangle
            {
                width: _ripple.width
                height: _ripple.height
                radius: control.radius
            }
        } // OpacityMask
    } // Ripple
} // Rectangle

// Copyright (c) 2017-2018, The Edollar Project
// 
// All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without modification, are
// permitted provided that the following conditions are met:
// 
// 1. Redistributions of source code must retain the above copyright notice, this list of
//    conditions and the following disclaimer.
// 
// 2. Redistributions in binary form must reproduce the above copyright notice, this list
//    of conditions and the following disclaimer in the documentation and/or other
//    materials provided with the distribution.
// 
// 3. Neither the name of the copyright holder nor the names of its contributors may be
//    used to endorse or promote products derived from this software without specific
//    prior written permission.
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
// MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
// THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
// STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
// THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

import QtQuick 2.0

Item {
    id: toggleswitch

    property bool on: false
    property int mWidth: width - height

    signal toggleChange(bool status)

    function updateBackground() {
        if (toggleswitch.state == "on")
            background.color = appWindow.primaryColor
    }

    function changeStatus(isOn) {
        console.log('State0: ', toggleswitch.state)
        on = isOn
        if (isOn) toggleswitch.state = "on"
        else toggleswitch.state = "off"
        console.log('State: ', toggleswitch.state)
        if (toggleswitch.state == 'on') {
            console.log('Change background color')
            background.color = appWindow.primaryColor
        } else {
            console.log('change background to off')
            background.color = '#bfbfbf'
        }
    }

    function toggle() {
        if (toggleswitch.state == "on") {
            toggleswitch.state = "off";
            background.color = '#bfbfbf'
        }
        else {
            toggleswitch.state = "on";
            background.color = appWindow.primaryColor
        }
        toggleChange(on)
    }

    function releaseSwitch() {
        if (knob.x == 1) {
            if (toggleswitch.state == "off") return;
        }
        if (knob.x == mWidth) {
            if (toggleswitch.state == "on") return;
        }
        toggle();
    }

    Rectangle {
        id: background
        width: parent.width
        height: parent.height
        color: '#bfbfbf' //appWindow.primaryColor
        radius: parent.height/2
        MouseArea { anchors.fill: parent; onClicked: toggle() }
    }

    Rectangle {
        id: knob
        x: 1; y: 2

        width: parent.height - 4
        height: parent.height - 4
        color: '#e6e6e6'
        radius: parent.height/2

        MouseArea {
            anchors.fill: parent
            drag.target: knob; drag.axis: Drag.XAxis; drag.minimumX: 1; drag.maximumX: mWidth
            onClicked: toggle()
            onReleased: releaseSwitch()
        }
    }

    states: [
        State {
            name: "on"
            PropertyChanges { target: knob; x: mWidth }
            PropertyChanges { target: toggleswitch; on: true }
        },
        State {
            name: "off"
            PropertyChanges { target: knob; x: 1 }
            PropertyChanges { target: toggleswitch; on: false }
        }
    ]

    transitions: Transition {
        NumberAnimation { properties: "x"; easing.type: Easing.InOutQuad; duration: 200 }
    }
}

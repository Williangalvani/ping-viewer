import QtQuick 2.12
import QtQuick.Shapes 1.12

Item {
    id: root
    width: 400
    height: width

    Shape {
        opacity: 0.5
        anchors.fill: parent
        vendorExtensionsEnabled: false

        // polar axis
        ShapePath {
            id: shapePathPolar
            fillColor: "transparent"
            strokeColor: "black"
            strokeWidth: 3
            strokeStyle: ShapePath.DashLine
            dashPattern: [2, 4]
            property var centerX: root.width/2
            property var centerY: root.height/2
            PathAngleArc {
                centerX: shapePathPolar.centerX
                centerY: shapePathPolar.centerY
                radiusX: root.width/2
                radiusY: root.height/2
                startAngle: 0
                sweepAngle: 360
            }

            PathAngleArc {
                centerX: shapePathPolar.centerX
                centerY: shapePathPolar.centerY
                radiusX: (3/4)*root.width/2
                radiusY: (3/4)*root.height/2
                startAngle: 0
                sweepAngle: 360
            }

            PathAngleArc {
                centerX: shapePathPolar.centerX
                centerY: shapePathPolar.centerY
                radiusX: (2/4)*root.width/2
                radiusY: (2/4)*root.height/2
                startAngle: 0
                sweepAngle: 360
            }

            PathAngleArc {
                centerX: shapePathPolar.centerX
                centerY: shapePathPolar.centerY
                radiusX: (1/4)*root.width/2
                radiusY: (1/4)*root.height/2
                startAngle: 0
                sweepAngle: 360
            }
        }

        ShapePath {
            fillColor: "transparent"
            strokeColor: "white"
            strokeWidth: 3
            strokeStyle: ShapePath.DashLine
            dashOffset: 3
            dashPattern: [2, 4]
            property var centerX: root.width/2
            property var centerY: root.height/2
            PathAngleArc {
                centerX: shapePathPolar.centerX
                centerY: shapePathPolar.centerY
                radiusX: root.width/2
                radiusY: root.height/2
                startAngle: 0
                sweepAngle: 360
            }

            PathAngleArc {
                centerX: shapePathPolar.centerX
                centerY: shapePathPolar.centerY
                radiusX: (3/4)*root.width/2
                radiusY: (3/4)*root.height/2
                startAngle: 0
                sweepAngle: 360
            }

            PathAngleArc {
                centerX: shapePathPolar.centerX
                centerY: shapePathPolar.centerY
                radiusX: (2/4)*root.width/2
                radiusY: (2/4)*root.height/2
                startAngle: 0
                sweepAngle: 360
            }

            PathAngleArc {
                centerX: shapePathPolar.centerX
                centerY: shapePathPolar.centerY
                radiusX: (1/4)*root.width/2
                radiusY: (1/4)*root.height/2
                startAngle: 0
                sweepAngle: 360
            }
        }
    }
}
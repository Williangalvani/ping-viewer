import QtGraphicalEffects 1.0
import QtQuick 2.7
import QtQuick.Controls 2.2
import QtQuick.Controls 1.4 as QC1
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0
import Waterfall 1.0

import Qt3D.Core 2.0
import Qt3D.Render 2.9
import Qt3D.Input 2.0
import QtQuick 2.2 as QQ2
import QtQuick.Scene2D 2.9
import QtQuick.Scene3D 2.0
import QtQuick.Window 2.0 as QW2
import Qt3D.Extras 2.9
import QtMultimedia 5.6 as QMM
import QtQuick.Dialogs 1.0

import SettingsManager 1.0
import StyleManager 1.0

Item {
    id: visualizer
    property alias waterfallItem: waterfall
    property var protocol

    onWidthChanged: {
        if(chart.Layout.minimumWidth === chart.width) {
            waterfall.width = width - chart.width
        }
    }

    function draw(points, confidence, initialPoint, length, distance) {
        waterfall.draw(points, confidence, initialPoint, length, distance)
        chart.draw(points, length + initialPoint, initialPoint)
    }

    function setDepth(depth) {
        depthAxis.depth_mm = depth
        readout.value = depth
    }

    function setConfidence(perc) {
        readout.confidence = perc
    }

    QC1.SplitView {
        orientation: Qt.Horizontal
        anchors.fill: parent

        Scene3D {
            id: scene3d
            anchors.fill: parent
            anchors.margins: 10
            focus: true
            aspects: ["input", "logic"]
            cameraAspectRatioMode: Scene3D.AutomaticAspectRatio

            Entity {
                id: sceneRoot

                Camera {
                    id: camera
                    projectionType: CameraLens.PerspectiveProjection
                    fieldOfView: 45
                    aspectRatio: visualizer.width / visualizer.height
                    nearPlane : 0.1
                    farPlane : 1000.0
                    position: Qt.vector3d( 0.0, 2.0, 0.0 )
                    upVector: Qt.vector3d( 0.0, 1.0, 0.0 )
                    viewCenter: Qt.vector3d( 0.0, 0.0, 0.0 )
                }

                Scene2D {
                    output: RenderTargetOutput {
                        attachmentPoint: RenderTargetOutput.Color0
                        texture: Texture2D {
                            id: offscreenTexture
                            width: 1280
                            height: 720
                            format: Texture.RGBA8_UNorm
                            generateMipMaps: false
                            magnificationFilter: Texture.Linear
                            minificationFilter: Texture.Linear
                            wrapMode {
                                x: WrapMode.ClampToEdge
                                y: WrapMode.ClampToEdge
                            }
                        }
                    }
                    QQ2.Rectangle {
                        width: offscreenTexture.width
                        height: offscreenTexture.height
                        color: "green"

                        QMM.MediaPlayer {
                            id: player
                            autoPlay: false
                            loops: QMM.MediaPlayer.Infinite
                        }

                        QMM.VideoOutput {
                            id: videoOutput
                            source: player
                            anchors.fill: parent
                        }
                    }
                }

                FirstPersonCameraController {
                    camera: camera
                }

                components: [
                    RenderSettings {
                        activeFrameGraph:
                            ForwardRenderer {
                                camera: camera
                            }
                    },
                    InputSettings {}
                ]

                Mesh {
                    id: mesh
                    source: "qrc:/models/sonarstuff.obj"
                }

                Entity {
                    id: entity

                    property Transform transform: Transform {
                        scale: 1
                        translation: Qt.vector3d(0,0,0)
                    }

                    property Material material: TextureMaterial {
                        texture: offscreenTexture
                    }

                    components: [mesh, material, transform]
                }

                FileDialog {
                    id: fileDialog
                    title: "Please choose a video"
                    folder: shortcuts.home
                    onAccepted: {
                        visible = false
                        player.source = fileDialog.fileUrl
                        player.play()
                    }
                    onRejected: {
                        Qt.quit()
                    }
                    QQ2.Component.onCompleted: {
                        visible = true
                    }
                }
            }

        }

        Waterfall {
            id: waterfall
            Layout.fillHeight: true
            Layout.fillWidth: false
            Layout.preferredWidth: 350
            Layout.minimumWidth: 350
            visible: false

            Rectangle {
                x: waterfall.mousePos.x - width/2 + height/2
                y: width/2
                height: 15
                width: waterfall.height
                transform: Rotation { origin.x: height/2; angle: 90}
                visible: waterfall.containsMouse
                gradient: Gradient {
                    GradientStop { position: 0.3; color: "transparent" }
                    GradientStop { position: 0.5; color: StyleManager.secondaryColor } // Not working with material
                    GradientStop { position: 0.8; color: "transparent" }
                }

                ColumnLayout {
                    x: waterfall.mousePos.y - width/2
                    y: -height*2
                    rotation: -90
                    Text {
                        id: mouseReadout
                        text: (waterfall.mouseColumnDepth*SettingsManager.distanceUnits['distanceScalar']).toFixed(2) + SettingsManager.distanceUnits['distance']
                        color: confidenceToColor(waterfall.mouseColumnConfidence)
                        font.family: "Arial"
                        font.pointSize: 15
                        font.bold: true

                        Text {
                            id: mouseConfidenceText
                            x: mouseReadout.width - width
                            y: mouseReadout.height*4/5
                            text: transformValue(waterfall.mouseColumnConfidence) + "%"
                            visible: typeof(waterfall.mouseColumnConfidence) == "number"
                            color: confidenceToColor(waterfall.mouseColumnConfidence)
                            font.family: "Arial"
                            font.pointSize: 10
                            font.bold: true
                        }
                    }
                }
            }

            DepthAxis {
                id: depthAxis
                anchors.fill: parent
                start_mm: waterfall.minDepthToDraw
                end_mm: waterfall.maxDepthToDraw
                visible: start_mm != end_mm
            }
        }

        Chart {
            id: chart
            Layout.fillHeight: true
            Layout.maximumWidth: 250
            Layout.preferredWidth: 100
            Layout.minimumWidth: 75
            // TODO these should be properties of the Ping1DVisualizer
            maxDepthToDraw: waterfall.maxDepthToDraw
            minDepthToDraw: waterfall.minDepthToDraw
        }

        Settings {
            property alias chartWidth: chart.width
        }
    }

    ValueReadout {
        id: readout
    }

    function confidenceToColor(confidence) {
        return Qt.rgba(2*(1 - confidence/100), 2*confidence/100, 0)
    }

    function transformValue(value, precision) {
        return typeof(value) == "number" ? value.toFixed(precision) : value + ' '
    }
}

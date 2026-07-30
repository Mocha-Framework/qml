import QtQuick 2.15

ShaderEffect {
    id: root

    // ==========================================
    // Public API
    // ==========================================
    property color color1: Theme.colors.primary
    property color color2: Qt.rgba(1.0, 1.0, 1.0, 0.15)
    property real time: 0.0

    // Aspect ratio multiplier to keep stripes square (not stretched)
    readonly property real aspect: height > 0 ? width / height : 1.0

    // Animates the stripes position smoothly
    NumberAnimation on time {
        from: 0.0
        to: 1.0
        duration: 1500
        loops: Animation.Infinite
    }

    // ==========================================
    // GPU Shader
    // ==========================================
    fragmentShader: "
        varying highp vec2 qt_TexCoord0;
        uniform lowp float qt_Opacity;
        uniform lowp vec4 color1;
        uniform lowp vec4 color2;
        uniform highp float time;
        uniform highp float aspect;
        void main() {
            highp vec2 coord = qt_TexCoord0;
            // Scale X by aspect ratio to preserve a true 45-degree angle
            coord.x *= aspect;

            // 45 degrees rotation matrix rotation
            highp float c = 0.70710678;
            highp float s = 0.70710678;
            highp vec2 rotated = vec2(coord.x * c - coord.y * s, coord.x * s + coord.y * c);

            // Repeat pattern (adjust stripeScale to control stripe thickness)
            highp float stripeScale = 8.0;
            highp float value = mod(rotated.x * stripeScale - time, 1.0);

            // Composite translucent color2 (stripes) over color1 (base)
            lowp vec4 stripeColor = color2;
            lowp vec4 baseColor = color1;
            
            // Mix RGB values based on stripeColor alpha
            lowp vec3 mixedRgb = mix(baseColor.rgb, vec3(1.0, 1.0, 1.0), stripeColor.a);
            lowp vec4 blendedColor = vec4(mixedRgb, baseColor.a);
            
            // Alternate between base color and blended color
            lowp vec4 finalColor = mix(baseColor, blendedColor, step(0.5, value));

            gl_FragColor = finalColor * qt_Opacity;
        }
    "
}

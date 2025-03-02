shader_type canvas_item;

// Слайдер для регулировки силы эффекта (0.0 - нет грязи, 1.0 - максимум)
uniform float dirt_amount : hint_range(0, 1) = 0.5;

// Текстура шума (в Inspector назначьте свою noise.png)
uniform sampler2D noise_texture;

// Цвет «грязи» (можно менять в Inspector)
uniform vec4 dirt_color : source_color = vec4(0.6, 0.5, 0.3, 1.0);
uniform float noise_scale : hint_range(0.1, 10.0) = 1.0;

void fragment() {
    // Исходный цвет пикселя из TEXTURE
    vec4 base_color = texture(TEXTURE, UV);
    vec2 scaled_uv = UV * noise_scale;
    vec4 noise = texture(noise_texture, scaled_uv);


    // Семплим шум из noise_texture по тем же UV
    // (при желании можно менять масштаб UV, если шум выглядит слишком крупно или мелко)
    //vec4 noise = texture(noise_texture, UV);

    // Пример простого смешения: берём яркость шума (noise.r) и смешиваем с dirt_color
    // Чем выше noise.r, тем сильнее проявляется "грязь".
    // Умножаем всё это на dirt_amount, чтобы иметь контроль над интенсивностью.
    float intensity = noise.r * dirt_amount;

    // Способ 1: затемняем базовый цвет и добавляем грязный оттенок
    // Можно смешать через mix() или просто умножить:
     base_color.rgb = mix(base_color.rgb, dirt_color.rgb, intensity);

    // Способ 2: чуть затемним базу и добавим оттенок dirt_color
    //base_color.rgb = base_color.rgb * (1.0 - intensity) + dirt_color.rgb * intensity * 0.3;

    // Записываем итог в COLOR
    COLOR = base_color;
}

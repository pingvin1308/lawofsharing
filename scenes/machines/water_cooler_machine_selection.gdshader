shader_type canvas_item;

const vec4 outline_color = vec4(1.0, 1.0, 1.0, 1.0); // белый цвет контура
const float outline_size = 1.0; // размер смещения для проверки соседей
uniform bool is_enabled = false;

void fragment() {
	if (is_enabled == true) {
		// Получаем цвет основного текстурного пикселя
	    vec4 tex_color = texture(TEXTURE, UV);
	    
	    // Определяем значение альфа основного пикселя
	    float alpha = tex_color.a;
	    
	    // Флаг наличия непрозрачного соседа
	    bool has_neighbor = false;
	    
	    // Пробегаем по соседним пикселям (3x3)
	    for (int x = -1; x <= 1; x++) {
	        for (int y = -1; y <= 1; y++) {
	            // Пропускаем центральный пиксель
	            if(x == 0 && y == 0)
	                continue;
	            
	            // Вычисляем смещение относительно текущего UV
	            vec2 offset = vec2(float(x), float(y)) * outline_size * TEXTURE_PIXEL_SIZE;
	            
	            // Получаем цвет соседнего пикселя
	            vec4 sample = texture(TEXTURE, UV + offset);
	            
	            // Если соседний пиксель непрозрачный, отмечаем наличие соседа
	            if(sample.a > 0.1) {
	                has_neighbor = true;
	            }
	        }
	    }
	    
	    // Если текущий пиксель прозрачный, но есть непрозрачный сосед — рисуем контур
	    if(alpha < 0.1 && has_neighbor) {
	        COLOR = outline_color;
	    } else {
	        COLOR = tex_color;
	    }
	}
}

shader_type canvas_item;

uniform sampler2D transition_texture : filter_nearest; 
uniform float transition : hint_range(0.0, 1.0) = 0.0;

uniform vec2 grid_x_y = vec2(8.0, 4.0);

uniform float edge_softness : hint_range(0.0, 0.05) = 0.01;

void fragment() {
	// 让圆在“屏幕空间”里保持正圆（防止宽屏下变椭圆）
	float aspect = (SCREEN_PIXEL_SIZE.y * grid_x_y.y) / (SCREEN_PIXEL_SIZE.x * grid_x_y.x); // = screen_w / screen_h
	vec2 aspect_vec = vec2(aspect, 1.0);
	vec2 uv = UV;

	// 分到每个格子里的局部坐标 [0,1)
	vec2 cell_uv = fract(uv * grid_x_y);
	cell_uv.x = cell_uv.x * aspect;

	// 以格子中心为原点
	vec2 p = cell_uv - aspect_vec * 0.5;
	

	// 到中心距离：中心=0，角落=0.7071...
	float d = length(p);

	// 格子的“对角线半径”
	float r_need_min = 0.0;
	float r_need_max = length(aspect_vec * 0.5) + 1.0;
	float r = mix(r_need_min, r_need_max, transition) - uv.x; // 圆半径随 transition 增大，同时向右移动（制造从左到右的转场效果）

	// 圆的遮罩：圆内=1，圆外=0（smoothstep 做软边）
	float mask = 1.0 - smoothstep(r - edge_softness, r + edge_softness, d);

	vec3 transition_color = texture(transition_texture, uv).rgb;

	// 黑色圆形，透明背景（用在 ColorRect 上做转场叠加很方便）
	COLOR = vec4(transition_color, mask);
}
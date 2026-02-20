shader_type canvas_item;

// 主体：nearest，保持像素感
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest_mipmap;
// Bloom：linear，只用于模糊（不影响主体采样）
uniform sampler2D SCREEN_TEXTURE_LIN : hint_screen_texture, filter_linear_mipmap;

// --- Bloom ---
uniform float bloom_threshold   : hint_range(0.0, 2.0)   = 1.0;   // 越高越不容易泛光（0.9~1.2）
uniform float bloom_soft_knee   : hint_range(0.0, 1.0)   = 0.35;  // 过渡柔和度
uniform float bloom_intensity   : hint_range(0.0, 1.0)  = 0.45;  // 泛光强度
uniform float bloom_radius_px   : hint_range(0.0, 5.0) = 3.0;   // 模糊半径（像素单位，推荐 2~6）

// --- CRT ---
uniform float curvature         : hint_range(0.0, 0.25) = 0.06;
uniform float scanline_strength : hint_range(0.0, 0.35) = 0.10;
uniform float vignette_strength : hint_range(0.0, 0.6)  = 0.22;
uniform float chroma_offset_px  : hint_range(0.0, 2.5)  = 0.75;
uniform float noise_strength    : hint_range(0.0, 0.15) = 0.03;

// --- helpers ---
float hash(vec2 p) {
	p = fract(p * vec2(123.34, 345.45));
	p += dot(p, p + 34.345);
	return fract(p.x * p.y);
}

vec2 barrel_distort(vec2 uv, float k) {
	vec2 cc = uv * 2.0 - 1.0;
	float r2 = dot(cc, cc);
	cc *= (1.0 + k * r2);
	return (cc * 0.5 + 0.5);
}

float luminance(vec3 c) {
	return dot(c, vec3(0.2126, 0.7152, 0.0722));
}

// soft threshold：让高亮提取更自然
float soft_threshold(float x, float threshold, float knee) {
	float t = threshold;
	float k = max(1e-5, knee);
	float a = x - t;
	float s = clamp((a + k) / (2.0 * k), 0.0, 1.0);
	float smoothFactor = s * s * (3.0 - 2.0 * s);
	return max(a, 0.0) * smoothFactor;
}

// 关键：先在每个 tap 里提取“高亮部分”，再做 blur
vec3 sample_bright(vec2 uv) {
	vec3 c = texture(SCREEN_TEXTURE_LIN, uv).rgb;
	float l = luminance(c);
	float high = soft_threshold(l, bloom_threshold, bloom_soft_knee);
	float keep = (l > 1e-5) ? clamp(high / l, 0.0, 1.0) : 0.0;
	return c * keep;
}

// 9-tap blur（对 bright 做 blur，这样 bloom 会溢出到物体外）
vec3 bloom_blur_bright(vec2 uv, vec2 texel, float radius_px) {
	vec2 r = texel * radius_px;

	vec3 c0 = sample_bright(uv);

	vec3 c1 = sample_bright(uv + vec2( r.x, 0.0));
	vec3 c2 = sample_bright(uv + vec2(-r.x, 0.0));
	vec3 c3 = sample_bright(uv + vec2(0.0,  r.y));
	vec3 c4 = sample_bright(uv + vec2(0.0, -r.y));

	vec3 c5 = sample_bright(uv + vec2( r.x,  r.y));
	vec3 c6 = sample_bright(uv + vec2(-r.x,  r.y));
	vec3 c7 = sample_bright(uv + vec2( r.x, -r.y));
	vec3 c8 = sample_bright(uv + vec2(-r.x, -r.y));

	// 简单近似高斯权重
	return c0 * 0.20
		 + (c1 + c2 + c3 + c4) * 0.12
		 + (c5 + c6 + c7 + c8) * 0.08;
}

void fragment() {
	vec2 uv = SCREEN_UV;

	// 曲率
	vec2 duv = barrel_distort(uv, curvature);

	// 屏幕外裁切（这里必须 return）
	if (duv.x < 0.0 || duv.x > 1.0 || duv.y < 0.0 || duv.y > 1.0) {
		COLOR = vec4(0.0, 0.0, 0.0, 1.0);
	}

	vec2 texel = 1.0 / vec2(textureSize(SCREEN_TEXTURE, 0));

	// ========= 1) Bloom（先做）=========
	vec3 bloom_term = bloom_blur_bright(duv, texel, bloom_radius_px) * bloom_intensity;

	// ========= 2) CRT（后做） =========
	// 色散：主体用 nearest 采样
	vec2 off = vec2(chroma_offset_px, 0.0) * texel;
	float r = texture(SCREEN_TEXTURE, duv + off).r;
	float g = texture(SCREEN_TEXTURE, duv).g;
	float b = texture(SCREEN_TEXTURE, duv - off).b;
	vec3 col = vec3(r, g, b);

	// 叠加 bloom（先加再做扫描线/暗角，更统一）
	col += bloom_term;

	// 扫描线
	float y = duv.y * float(textureSize(SCREEN_TEXTURE, 0).y);
	float scan = 0.5 + 0.5 * sin(y * 3.14159265);
	col *= mix(1.0, scan, scanline_strength);

	// 暗角
	vec2 p = duv - 0.5;
	float v = smoothstep(0.85, 0.25, dot(p, p) * 1.6);
	col *= mix(1.0, v, vignette_strength);

	// 噪声
	float n = hash(duv * (vec2(textureSize(SCREEN_TEXTURE, 0)) * 0.5) + TIME);
	col += (n - 0.5) * noise_strength;

	COLOR = vec4(col, 1.0);
}
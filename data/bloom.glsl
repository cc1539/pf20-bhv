uniform sampler2D canvas;

const uniform float amount = 3e-3;
const uniform float threshold = 75.;
const uniform int range = 15;

vec4 getSample(vec2 coord) {
	return texture(canvas,coord/textureSize(canvas,0));
}

vec4 getSpreadAverage(vec2 coord) {
	vec4 avg = vec4(0.0);
	for(int i=-range;i<=range;i++) {
	for(int j=-range;j<=range;j++) {
		vec2 offset = vec2(float(i),float(j));
		float r = length(offset);
		if(r<=float(range)) {
			//float factor = 1.0/(1.0+r*r);
			float factor = 1.0;
			avg += getSample(coord+offset)*factor;
		}
	}
	}
	return avg;
}

void main() {
	vec2 coord = gl_FragCoord.xy;
	vec3 bloom = max(vec3(0.0),(getSpreadAverage(coord)-threshold).rgb);
	gl_FragColor = getSample(coord)+vec4(bloom*amount,0.0);
}

uniform vec2 windowSize;
uniform sampler2D skymap;
uniform int maxIterations;
uniform bool portal;

uniform vec3 cameraPos;
uniform mat3 cameraLook;
uniform vec2 cameraView;
uniform float cameraJitter;

uniform vec3 blackHolePos;
uniform float blackHoleSpin;
uniform float blackHoleRadius;

uniform float accretionDiskRadius;
uniform float accretionDiskBrightness;
uniform float accretionDiskThickness;
uniform vec3 accretionDiskOuterColor;
uniform vec3 accretionDiskInnerColor;
uniform float accretionDiskDensity;

uniform float minCloudStep;
uniform float maxCloudStep;
uniform int cloudOctaves[10];
uniform int cloudOctaveCount;

uniform float time;

uniform const float PI = 3.14159265358;

// dependents
uniform float rMin;
uniform float rMax;
uniform float rMin2;
uniform float rMax2;
uniform float adt;


// adapted from "The Book of Shaders" by @patriciogv
float random(vec3 coord) {
    return fract(sin(dot(coord,vec3(12.9898,78.2330,471.1698)))*43758.5453123);
}

// ripped from http://lolengine.net/blog/2013/07/27/rgb-to-hsv-in-glsl
vec3 rgb2hsv(vec3 c) {
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

// ripped from http://lolengine.net/blog/2013/07/27/rgb-to-hsv-in-glsl
vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

float lerpNoise(vec3 coord) {
	vec3 base = floor(coord);
	vec3 next = base+vec3(1.0);
	return mix(mix(
		mix(random(vec3(base.x,base.y,base.z)),random(vec3(next.x,base.y,base.z)),fract(coord.x)),
		mix(random(vec3(base.x,next.y,base.z)),random(vec3(next.x,next.y,base.z)),fract(coord.x)),
		fract(coord.y)),
		mix(
		mix(random(vec3(base.x,base.y,next.z)),random(vec3(next.x,base.y,next.z)),fract(coord.x)),
		mix(random(vec3(base.x,next.y,next.z)),random(vec3(next.x,next.y,next.z)),fract(coord.x)),
		fract(coord.y)),
		fract(coord.z));
}

vec3 rotateY(vec3 coord, float angle) {
	float ca = cos(angle);
	float sa = sin(angle);
	//vec2 newxz = coord.xz*ca+coord.zx*vec2(-1.0,1.0)*sa;
	return vec3(
		coord.x*ca-coord.z*sa,
		coord.y,
		coord.x*sa+coord.z*ca
	);
	//return vec3(newxz.x,coord.y,newxz.y);
}

float fractalNoise(vec3 coord) {
	float total = 0.0;
	float len = length(coord);
	vec3 unit = normalize(coord);
	int i0 = min(cloudOctaveCount-2,int(sqrt(length(coord-cameraPos))/20.));
	float scale = float(cloudOctaveCount)/float(cloudOctaveCount-i0);
	for(int i=i0;i<cloudOctaveCount;i++) {
		float fi = float(cloudOctaves[i]+1);
		// offset is the part that makes the accretion disk less chunky
		//float offset = dot(vec3(time,len,cos(dot(vec2(coord.y,time),vec2(0.03,0.01)))),vec3(0.01,0.02,2.0));
		float offset = time*0.01+len*0.02+cos(coord.y*0.03+time*0.01)*2.0;
		float factor = (len/1e3+1.0)*0.5/exp(fi);
		total += lerpNoise(rotateY(coord,(time/(fi*fi))/*(3e9/(len*len))*/)*factor+vec3(0.0,offset,0.0));
	}
	return total*scale;
}

float accretionDiskPower(vec3 coord) {
	coord -= blackHolePos;
	if(abs(coord.y)>accretionDiskThickness) {
		return 0.0;
	}
	float diskLen = length(coord.xz);
	if(diskLen>=rMax) { return 0.0; }
	if(diskLen<=rMin) { return 0.0; }
	float xzPower = rMax2*rMin2*(1.0/(diskLen*diskLen)-1.0/rMax2)/(rMax2-rMin2);
	float yPower = sqrt(1.0-pow(coord.y/accretionDiskThickness,2))*fractalNoise(coord);
	return xzPower*yPower*(1.0-xzPower);
}

float noiseSum(vec3 coord0, vec3 coord1, inout vec3 tintSum) {
	
	coord0 -= blackHolePos;
	coord1 -= blackHolePos;
	
	vec3 dir = coord1-coord0;
	vec3 pos0 = coord0;
	vec3 pos1 = coord1;
	
	float t0 = -1.0;
	float t1 = -1.0;
	
	if(pos0.y<-adt) { pos0 += dir*(t0=((-adt-pos0.y)/dir.y)); }
	if(pos0.y> adt) { pos0 += dir*(t0=(( adt-pos0.y)/dir.y)); }
	dir = pos1-pos0;
	
	if(pos1.y<-adt) { pos1 += dir*(t1=((-adt-pos1.y)/dir.y)); }
	if(pos1.y> adt) { pos1 += dir*(t1=(( adt-pos1.y)/dir.y)); }
	dir = pos1-pos0;
	
	if(!((false
		||((coord0.y> adt)!=(coord1.y> adt))
		||((coord0.y>-adt)!=(coord1.y>-adt))
		||(coord0.y>-adt && coord0.y<adt)
		||(coord1.y>-adt && coord1.y<adt))
		&&(length(coord0)<accretionDiskRadius*1.2 ||
		   length(coord1)<accretionDiskRadius*1.2)
	)) {
		return 0.0;
	}
	
	float aCloudStep = min(maxCloudStep,max(minCloudStep,length(coord1-cameraPos)/50)); // adaptive cloud step
	
	float total = 0.0;
	float len = length(dir);
	vec3 move = dir/len*aCloudStep;
	// then we use coord0 as the rayPos and uniformly step through the cloud
	for(float i=0.0;i<len;i+=aCloudStep) {
		float contrib = fractalNoise(pos0)*accretionDiskPower(pos0);
		total += contrib;
		pos0 += move;
		float lerp = 1.0/(pow(length(pos0)-blackHoleRadius*3.0,2)/1e5+1.0);
		vec3 diskColor = mix(accretionDiskOuterColor,accretionDiskInnerColor,lerp);
		tintSum += contrib*aCloudStep*accretionDiskBrightness*diskColor;
	}
	return total*aCloudStep;
}

float getSphereDistance(vec3 coord, vec3 spherePos, float r) {
	return abs(length(coord-spherePos)-r);
}

void main() {
	
	vec2 coord = gl_FragCoord.xy/windowSize*2.0-vec2(1.0); // convert to default OpenGL coords
	vec3 rayPos = cameraPos;
	vec3 rayDir = cameraLook[2];
	rayDir += cameraLook[0]*(coord.x*cameraView.x+(random(vec3(coord,1.0)+vec3(sin(time*.3)))*2.0-1.0)*cameraJitter);
	rayDir += cameraLook[1]*(coord.y*cameraView.y+(random(vec3(coord,0.5)+vec3(sin(time*.5)))*2.0-1.0)*cameraJitter);
	rayDir = normalize(rayDir);
	
	vec3 tint = vec3(0.0);
	float occlude = 0.0;
	float doppler = 0.0;
	
	bool absorbed = false;
	
	for(int i=0;i<maxIterations;i++) {
		
		float rdst = length(rayPos-blackHolePos);
		if(rdst<=blackHoleRadius) {
			absorbed = true;
			if(portal) {
				rayDir = reflect(rayDir,normalize(rayPos-blackHolePos));
			} else {
				break;
			}
		}
		
		// apply gravity
		vec3 diff = (blackHolePos-rayPos)/blackHoleRadius;
		float diff2 = dot(diff,diff);
		//float grav = 1.0/sqrt(sqrt(diff2));
		float grav = 1.0/diff2;
		if(grav<1e-5 && rdst>accretionDiskRadius) { // too far away for gravity
			break;
		}
		
		vec3 unit = normalize(diff);
		doppler += grav*dot(rayDir,unit)*3e-1;
		rayDir = normalize(rayDir+(unit+vec3(unit.z,0.0,-unit.x)*blackHoleSpin)*grav);
		
		// move ray forward
		float dst = getSphereDistance(rayPos,blackHolePos,blackHoleRadius);
		vec3 rayDsp = rayDir*dst;
		vec3 tintSum = vec3(0.0);
		float cloudPower = noiseSum(rayPos,rayPos+rayDsp,tintSum); // volumetric clouds
		rayPos += rayDsp;
		
		occlude += cloudPower*accretionDiskDensity+1e-4;
		tint += tintSum;
	}
	
	float twinkle = random(rayPos+vec3(time,time*2.0,time*5.0));
	vec3 pixel = vec3(0.0);
	if(occlude<1.0 && (!absorbed || portal)) {
		// convert rayDir to spherical coordinates
		vec2 sphereCoord = vec2((atan(rayDir.y,rayDir.x)/PI+1.0)*0.5,acos(rayDir.z)/PI);
		pixel = mix(texture2D(skymap,sphereCoord).rgb*(twinkle*.5+.2),vec3(0.0),occlude);
	}
	pixel += tint;
	
	gl_FragColor = vec4(pixel,1.0);
}

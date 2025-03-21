shader_type canvas_item;

uniform ivec2 RESOLUTION;

vec4 coord(inout vec4 uv, vec2 grid)
{
	vec2 coord;
	// center 0, 0
	uv = (uv - .5) * 2.;
	uv.y = -uv.y;
	// balance the aspect ratio
	float aspect = float(RESOLUTION.x)/float(RESOLUTION.y);
	uv.x *= aspect;
	// add gridding
	coord = uv.xy;
	coord *= grid/2.;
	coord = mod(coord, 1.);
	vec2 id=floor(coord);

	return vec4(coord, id);
}
void BlendColour(inout vec4 col, vec4 colour)
{
	col = (col*(1.-colour.a))+(colour*colour.a);
}
void Circle(inout vec4 col, vec4 coord, vec3 pos, float radius, vec4 colour)
{
	if(length(coord.xy - pos.xy)<radius)
	{
		BlendColour(colour, col);
	}
}
void Square(inout vec4 col, vec4 coord, vec3 pos, float sides, vec4 colour)
{
	if(length(coord.x - pos.x)<sides && length(coord.y - pos.y)<sides)
	{
		col=colour;
	}
}
void Wave(inout vec4 col, vec4 coord, vec3 pos, float amp, float freq, float thickness, vec4 colour)
{
	float alpha = colour.a;

	float function = sin((coord.x+pos.x)*freq)*amp;

	float l =  clamp(0., 1.,length(coord.xy - vec2(coord.x, function+pos.y)));
	colour.a = pow((1.+thickness)-l, 10.)/2.;
	if(l<thickness) colour.a = alpha;

	BlendColour(colour, col);
	col=colour;
}
void HLine(inout vec4 col, vec4 coord, vec3 pos,float thickness, vec4 colour)
{
	if(length(coord.y - pos.y)<thickness)
	{
		col=colour;
	}
}
void Point(inout vec4 col, vec4 coord, vec3 pos,float size, vec4 colour)
{
	if(length(pos.xy-coord.xy)<size)
	{
		col=colour;
	}
}

void fragment() {
	vec4 uv = vec4(UV, 0., 0.);
	vec4 coord = coord(uv, vec2(5.,5.));
	vec4 col = vec4(0,0,0,1);

	// add scene elements
	//Square(col, coord, vec3(.5,0,2), .7, vec4(0,0,1,1));
	//Circle(col, coord, vec3(0,0,2), .7, vec4(0,1,0,.1));
	Wave(col, uv, vec3(0., 0., 0.),.7, 5., .09, vec4(0,1,0,1));
	HLine(col, coord, vec3(0., 0.0, 0.), .02, vec4(0,0,1,1));
	HLine(col, uv, vec3(0., 0.0, 0.), .02, vec4(0,0,1,1));
	Point(col, coord, vec3(0.,0.,0.), .05, vec4(1.,1.,1.,1.));
	COLOR = col;
}

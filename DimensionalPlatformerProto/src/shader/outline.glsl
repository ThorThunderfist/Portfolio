extern vec2 stepSize;
extern vec4 color;

vec4 effect( vec4 col, Image texture, vec2 texturePos, vec2 screenPos )
{
	number alpha = 4 * texture2D( texture, texturePos ).a;
	alpha -= texture2D( texture, texturePos + vec2( stepSize.x, 0.0f ) ).a;
	alpha -= texture2D( texture, texturePos + vec2( -stepSize.x, 0.0f ) ).a;
	alpha -= texture2D( texture, texturePos + vec2( 0.0f, stepSize.y ) ).a;
	alpha -= texture2D( texture, texturePos + vec2( 0.0f, -stepSize.y ) ).a;

	return vec4( color.r, color.g, color.b, alpha );
}
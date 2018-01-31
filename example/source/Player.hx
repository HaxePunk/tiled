import haxepunk.Entity;
import haxepunk.Graphic;
import haxepunk.HXP;
import haxepunk.math.MathUtil;
import haxepunk.math.Vector2;


class Player extends Entity
{
    public static inline var GRAVITY:Float = 980;
    public static inline var MAX_VEL:Float = 300;
    public static inline var JUMP_VEL:Float = -300;
    public static inline var GROUND_FRICTION:Float = 500;
    public static inline var GROUND_ACCEL:Float = 1200;
    public static inline var AIR_ACCEL:Float = 500;

    var _vel:Vector2;
    var _grounded:Bool;
    var _isMovingHorizontal:Bool;

    public function new( x:Float, y:Float, graphic:Graphic )
    {
        super( x, y, graphic );

        _vel = new Vector2();
    }

    override public function added():Void
    {
        _vel.setTo( 0, 0 );
        _grounded = false;
        _isMovingHorizontal = false;
    }

    override public function update():Void
    {
        applyVelocity();

        if( !_grounded ) applyGravity();
        else if ( !_isMovingHorizontal ) applyFriction();

        _isMovingHorizontal = false;
    }

    override public function moveCollideX( other:Entity ):Bool
    {
        if (other.type == "ground" && _vel.x != 0)
        {
            _vel.x = 0;
        }

        return true;
    }

    override public function moveCollideY( other:Entity ):Bool
    {
        // react if we are moving down and are on the ground
        if(other.type == "ground" && _vel.y > 0)
        {
            _vel.y = 0;
            _grounded = true;
        }

        return true;
    }

    public function jump():Void
    {
        if(_grounded)
        {
            _vel.y = JUMP_VEL;
            _grounded = false;
        }
    }

    public function moveLeft():Void
    {
        _isMovingHorizontal = true;

        _vel.x = -MathUtil.approach(
            -_vel.x,
            MAX_VEL,
            (_grounded ? GROUND_ACCEL : AIR_ACCEL) * HXP.elapsed * HXP.rate
        );
    }

    public function moveRight():Void
    {
        _isMovingHorizontal = true;

        _vel.x = MathUtil.approach(
            _vel.x,
            MAX_VEL,
            (_grounded ? GROUND_ACCEL : AIR_ACCEL) * HXP.elapsed * HXP.rate
        );
    }

    function applyVelocity():Void
    {
        moveBy(
            _vel.x * HXP.elapsed * HXP.rate,
            _vel.y * HXP.elapsed * HXP.rate,
            "ground",
            true
        );
    }

    function applyGravity():Void
    {
        _vel.y = MathUtil.approach(
            _vel.y,
            MAX_VEL,
            GRAVITY * HXP.elapsed * HXP.rate
        );
    }

    function applyFriction():Void
    {
        var sign = MathUtil.sign(_vel.x);
        var abs = Math.abs(_vel.x);
        var step = GROUND_FRICTION * HXP.elapsed * HXP.rate;

        if(abs > 0)
        {
            if(abs - step < 0) abs = 0;
            else abs -= step;
        }

        _vel.x = abs * sign;
    }
}
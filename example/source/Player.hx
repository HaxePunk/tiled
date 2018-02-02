import haxepunk.Entity;
import haxepunk.Graphic;
import haxepunk.HXP;
import haxepunk.math.MathUtil;
import haxepunk.math.Vector2;


class Player extends Entity
{
    public var gravity(default, null):Float;
    public var maxVel:Float;
    public var jumpVel:Float;
    public var groundFriction:Float;
    public var groundAccel:Float;
    public var airAccel:Float;

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

        if( !_grounded )
            applyGravity();
        else if ( !_isMovingHorizontal ) // If we are on the ground and no horizaontal movement commands were made this frame
            applyFriction();

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
        // stop if we hit the ground and are moving down
        if(other.type == "ground" && _vel.y > 0)
        {
            _vel.y = 0;
            _grounded = true;
        }

        return true;
    }

    public function setProperties(gravity:Float, maxVel:Float, jumpVel:Float, groundAccel:Float, groundFriction:Float, airAccel:Float):Void
    {
        this.gravity = gravity;
        this.maxVel = maxVel;
        this.jumpVel = jumpVel;
        this.groundAccel = groundAccel;
        this.groundFriction = groundFriction;
        this.airAccel = airAccel;
    }

    public function jump():Void
    {
        if(_grounded)
        {
            _vel.y = jumpVel;
            _grounded = false;
        }
    }

    public function moveLeft():Void
    {
        _isMovingHorizontal = true;

        // we negate here because approach() only works from the left
        _vel.x = -MathUtil.approach(
            -_vel.x,
            maxVel,
            (_grounded ? groundAccel : airAccel) * HXP.elapsed * HXP.rate
        );
    }

    public function moveRight():Void
    {
        _isMovingHorizontal = true;

        _vel.x = MathUtil.approach(
            _vel.x,
            maxVel,
            (_grounded ? groundAccel : airAccel) * HXP.elapsed * HXP.rate
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
            maxVel,
            gravity * HXP.elapsed * HXP.rate
        );
    }

    function applyFriction():Void
    {
        var sign = MathUtil.sign(_vel.x);
        var abs = Math.abs(_vel.x);
        var step = groundFriction * HXP.elapsed * HXP.rate;

        // we negate here because approach() only works from the left
        abs = -MathUtil.approach(
            -abs,
            0,
            step
        );

        _vel.x = abs * sign;
    }
}
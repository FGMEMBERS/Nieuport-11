#####################################################################################
#                                                                                   #
#         utilities for use with any YAsim rotary engine (YASim fdm)                #
#                                                                                   #
#####################################################################################

##############


# ================================ Initalize ======================================
# Make sure all needed properties are present and accounted
# for, and that they have sane default values.



props.globals.initNode("engines/engine[0]/rpm", 0.0, "DOUBLE");
props.globals.initNode("controls/gear/brake-left", 0.0, "DOUBLE");
props.globals.initNode("controls/gear/brake-right", 0.0, "DOUBLE");



var engine_running_Node = props.globals.initNode("engines/engine[0]/running", 1, "BOOL");

magneto = nil;


initialize = func {

    print( "Initializing engine utility ..." );

# initialize objects

    magneto = Magneto.new();

#set listeners
    setlistener( "controls/gear/brake-left", func { magneto.blipMagswitch();
    } );
    setlistener( "controls/gear/brake-right", func { magneto.blipMagswitch();
    } );

    setlistener( "controls/gear/brake-parking", func {
                if(getprop("gear/gear[0]/wow") and getprop("gear/gear[1]/wow")){
                    generic_bool1_Node.setValue(controls_gear_brake_parking_Node.getValue());
                }
            } );

# set it running on the next update cycle
    settimer( update, 0 );

    print( "... running engine utility" );

} # end func

###
# ====================== end Initialization ========================================
###

###
# ==== this is the Main Loop which keeps everything updated ========================
##
	update = func {


      	if ( getprop("engines/engine/rpm") <=150 and getprop("controls/engines/engine/blip_switch") ) {
			#print ("low speed mag check");
			magneto.blipMagswitch();
			} # endif

		settimer( update, 0 );

	}# end main loop func

# ============================== end Main Loop ===============================

# ============================== specify classes ===========================


# =========================== magneto stuff ====================================
# Class that specifies magneto functions
#
Magneto = {
    new : func ( name = "magneto",
    right = "controls/engines/engine/mag-switch-right",
    left = "controls/engines/engine/mag-switch-left",
    magnetos = "controls/engines/engine/magnetos",
    left_brake = "controls/gear/brake-left",
    right_brake = "controls/gear/brake-right",
	rpm = "engines/engine/rpm"
    ){
        var obj = { parents : [Magneto] };
        obj.name = name;
        obj.right = props.globals.getNode( right, 1 );
        obj.left = props.globals.getNode( left, 1 );
        obj.magnetos = props.globals.getNode( magnetos, 1 );
        obj.left_brake = props.globals.getNode( left_brake, 1 );
        obj.right_brake = props.globals.getNode( right_brake, 1 );
		obj.rpm = props.globals.getNode( rpm, 1 );
        obj.left.setBoolValue( 0 );
        obj.right.setBoolValue( 0 );
		obj.rpm.setDoubleValue( 0 );
        #print ( obj.name );
        return obj;
    },

updateMagnetos: func{     # set the magneto value according to the switch positions
 #print("updating Magnetos");
                if (me.left.getValue() and me.right.getValue()){                  # both
                    me.magnetos.setValue( 3 );
                }
                elsif (me.left.getValue() and !me.right.getValue()) {             # left
                    me.magnetos.setValue( 1 );
                }
                elsif (!me.left.getValue() and me.right.getValue()) {             # right
                    me.magnetos.setValue( 2 );
                }
                else{
                    me.magnetos.setValue( 0 );            # none
                }

    }, # end function

setleftMagswitch:   func ( left ) {

    me.left.setValue( left );
    me.updateMagnetos();

    }, # end function

setrightMagswitch:  func ( right) {

    me.right.setValue( right );
    me.updateMagnetos();

    }, # end function

toggleleftMagswitch:    func{
# print ("left in ", me.left.getValue());
    var left = me.left.getValue();
    left = !left;
    me.left.setBoolValue( left );
    me.updateMagnetos();

    }, # end function

togglerightMagswitch:   func{
# print ("right in ", me.right.getValue());
    var right = me.right.getValue();
    right = !right;
    me.right.setBoolValue( right );
    me.updateMagnetos();

    }, # end function

blipMagswitch:   func{
# print ("blip in right ", me.right.getValue()," left ", me.left.getValue());
# print ("blip in brake right ", me.right_brake.getValue()," left ", me.left_brake.getValue());

	if ( me.right_brake.getValue() != 0 or me.left_brake.getValue() != 0 ) {

		if (me.rpm.getValue() > 150){
#			print("150+", me.rpm.getValue()," mags ", me.magnetos.getValue());
			me.magnetos.setValue( 0 );
			} elsif (me.rpm.getValue() <= 150){
				me.magnetos.setValue( 1 );
#				print("-150", me.rpm.getValue(), " mags ", me.magnetos.getValue() );
			}

		setprop("controls/engines/engine/blip_switch", 1);
		
		} else {
			me.updateMagnetos();
			setprop("controls/engines/engine/blip_switch",0);
		}

# print ("blip out right ", me.right.getValue()," left ", me.left.getValue());
		}, # end function
    }; #
	      

# =============================== end magneto stuff =========================================

# Fire it all up

setlistener("sim/signals/fdm-initialized", initialize);

# end 

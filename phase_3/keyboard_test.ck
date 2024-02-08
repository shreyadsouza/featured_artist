Hid hi;
HidMsg msg;

2 => int device;
if( me.args() ) me.arg(0) => Std.atoi => device;
if( !hi.openKeyboard( device ) ) me.exit();


    while( 1 )
    {
        hi => now;
        while( hi.recv( msg ) )
        {
            if( msg.isButtonDown() )
            {
                // right shift key
                if (msg.which == 229){
                    chout <= "*BOOM*";  chout.flush(); 
                }

                // left shift key
                if (msg.which == 225){
                    chout <= "*TSSSS*";  chout.flush(); 
                }
            }
        
        }
    }


// spork ~ keyboardInput();
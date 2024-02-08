//------------------------------------------------------------------------------
// name: mosaic-synth-play.ck (v1.3)
// desc: basic structure for a feature-based synthesizer
//       here we generate our mosaic driven by a sound file,
//       played on the left channel, with the mosaic output
//       on the right channel.
// date: Spring 2023
// authors: Ge Wang (https://ccrma.stanford.edu/~ge/)
//          Yikai Li
//------------------------------------------------------------------------------

class AudioWindow
    {
        // unique point index (use this to lookup feature vector)
        int uid;
        // which file did this come file (in files arary)
        int fileIndex;
        // starting time in that file (in seconds)
        float windowTime;
        
        // set
        fun void set( int id, int fi, float wt )
        {
            id => uid;
            fi => fileIndex;
            wt => windowTime;
        }
    }

class FeaturesFile {

    string FEATURES_FILE;


        

    fun void setFile(string filepath){
        FEATURES_FILE => filepath;
    }

    fun void setup(){

        // values to be read from file
        0 => int numPoints; // number of points in data
        0 => int numCoeffs; // number of dimensions in data
        // file read PART 1: read over the file to get numPoints and numCoeffs
        loadFile( FEATURES_FILE ) @=> FileIO @ fin;
        // check
        if( !fin.good() ) me.exit();
        // check dimension at least
        if( numCoeffs != NUM_DIMENSIONS )
        {
            // error
            <<< "[error] expecting:", NUM_DIMENSIONS, "dimensions; but features file has:", numCoeffs >>>;
            // stop
            me.exit();
        }




        //------------------------------------------------------------------------------
        // each Point corresponds to one line in the input file, which is one audio window
        //------------------------------------------------------------------------------
        // array of all points in model file
        AudioWindow windows[numPoints];
        // unique filenames; we will append to this
        string files[0];
        // map of filenames loaded
        int filename2state[0];
        // feature vectors of data points
        float inFeatures[numPoints][numCoeffs];
        // generate array of unique indices
        int uids[numPoints]; for( int i; i < numPoints; i++ ) i => uids[i];

        // use this for new input
        float features[NUM_FRAMES][numCoeffs];
        // average values of coefficients across frames
        float featureMean[numCoeffs];



        //------------------------------------------------------------------------------
        // read the data
        //------------------------------------------------------------------------------
        readData( fin );


        //------------------------------------------------------------------------------
        // set up our KNN object to use for classification
        // (KNN2 is a fancier version of the KNN object)
        // -- run KNN2.help(); in a separate program to see its available functions --
        //------------------------------------------------------------------------------
        KNN2 knn;
        10 => int K;
        int knnResult[K];
        knn.train( inFeatures, uids );
    

    }
    



}


Hid hi;
HidMsg msg;


string FEATURES_FILE;
1 => int NUM_SOUNDS;

// which keyboard
1 => int device;
// get from command line

// open keyboard (get device number from command line)
if( !hi.openKeyboard( device ) ) me.exit();
<<< "keyboard '" + hi.name() + "' ready", "" >>>;


ConsoleInput in;
StringTokenizer tok;
string line[0];

FeaturesFile inputFeaturesFile;


in.prompt( "CHOOSE FEATURES FILE:
            [1]: Big Boys — SNL
            [2]: Rap Roundtable — SNL
            [3]: Whitney Houston — I Will Always Love You
            [4]: Queen — Bohemian Rhapsody
            [5]: Iggy Azalea — Fancy ft. Charli XCX
            [6]: Beyoncé — Single Ladies (Put a Ring on It)
            ") => now;
    // read
    while( in.more() )
    {
       // line.clear();
        tok.set( in.getLine() );
        while( tok.more() )
        {
            line << tok.next().lower();
        }

        if (line[0] == "1"){
            inputFeaturesFile.setFile("sza.txt");
        }
        else if (line[0] == "2"){
            "yeet.txt" => FEATURES_FILE;
        }
        else if (line[0] == "3"){
            "whitney.txt" => FEATURES_FILE;
        }
        else if (line[0] == "4"){
            "freddie.txt" => FEATURES_FILE;
        }
        else if (line[0] == "5"){
            "iggy.txt" => FEATURES_FILE;
        }
        else if (line[0] == "6"){
            "beyonce.txt" => FEATURES_FILE;
        }
        else           
        {
            <<< "Invalid input, exiting" >>>;
            me.exit();
        }
    }


SndBuf input => FFT fft;
FeatureCollector combo => blackhole;
fft =^ Centroid centroid =^ combo;
fft =^ Flux flux =^ combo;
fft =^ RMS rms =^ combo;
fft =^ MFCC mfcc =^ combo;
20 => mfcc.numCoeffs;
10 => mfcc.numFilters;
fft =^ RollOff rolloff =^ combo;
fft =^ ZeroX zerox =^ combo;

combo.upchuck();

in.prompt( "CHOOSE PITCH PERFECT CLIP:
            [1]: The Barden Bellas - 1
            [2]: The Treblemakers - 1
            [3]: The Barden Bellas - 2
            [4]: The Treblemakers - 2
            [5]: The Barden Bellas - 3
            [6]: The Barden Bellas - 4
            ") => now;
    // read
    while( in.more() )
    {
       // line.clear();
        tok.set( in.getLine() );
        while( tok.more() )
        {
            line << tok.next().lower();
        }

        if (line[0] == "1"){
            "data/pp/clip1.wav"=> input.read;
        }
        else if (line[0] == "2"){
            "data/pp/clip2.wav"=> input.read;
        }
        else if (line[0] == "3"){
            "data/pp/clip3.wav"=> input.read;
        }
        else if (line[0] == "4"){
            "data/pp/clip4.wav"=> input.read;
        }
        else if (line[0] == "5"){
            "data/pp/clip5.wav"=> input.read;
        }
        else if (line[0] == "6"){
            "data/pp/clip6.wav"=> input.read;
        }
        else           
        {
            <<< "Invalid input, exiting" >>>;
            me.exit();
        }
    }


fun void keyboardInput()
{
    while( true )
    {
        // wait on event
        hi => now;

        // get one or more messages
        while( hi.recv( msg ) )
        {
            // check for action type
            if( msg.isButtonDown() )
            {
                if (msg.which == 82) {
                    NUM_SOUNDS + 1 => NUM_SOUNDS;
                    <<< "ADDED SOUND!!! :)", "" >>>;                    
                }
            
            
            if (msg.which == 81 && NUM_SOUNDS >= 2)
            {
                     NUM_SOUNDS - 1 => NUM_SOUNDS;
                    <<< "REMOVED SOUND :(", "" >>>;
                
               
            }
        }
    }
    }
}



spork ~ keyboardInput();


//------------------------------------------------------------------------------
// setting up our synthesized audio input to be analyzed and mosaic'ed
//------------------------------------------------------------------------------
// // if we want to hear our audio input
input => Delay delay => Gain g => dac.left;
// add artificial delay for time alignment to mosaic output
100::ms => delay.max => delay.delay;
// scale the volume
0.5 => g.gain;

//-----------------------------------------------------------------------------
// setting analysis parameters -- also should match what was used during extration
//-----------------------------------------------------------------------------
// set number of coefficients in MFCC (how many we get out)

// get number of total feature dimensions
combo.fvals().size() => int NUM_DIMENSIONS;

4096 => fft.size;
Windowing.hann(fft.size()) => fft.window;
(fft.size()/1.2)::samp => dur HOP;
4 => int NUM_FRAMES;
// how much time to aggregate features for each file
fft.size()::samp * NUM_FRAMES => dur EXTRACT_TIME;


//------------------------------------------------------------------------------
// unit generator network: for real-time sound synthesis
//------------------------------------------------------------------------------
100 => int NUM_VOICES;
SndBuf buffers[NUM_VOICES]; ADSR envs[NUM_VOICES]; Pan2 pans[NUM_VOICES]; NRev mixes[NUM_VOICES];
for( int i; i < NUM_VOICES; i++ )
{
    buffers[i] => envs[i] => dac;
    fft.size() => buffers[i].chunks;
    1 => buffers[i].gain;
    Math.random2f(-.75,.75) => pans[i].pan;
    Math.random2f(-.75,.75) => mixes[i].mix;
    envs[i].set( EXTRACT_TIME, EXTRACT_TIME/256, 1, EXTRACT_TIME );
}




//------------------------------------------------------------------------------
// load feature data; read important global values like numPoints and numCoeffs
//------------------------------------------------------------------------------

// CREATE A CLASS/ OR REFACTORING



// used to rotate sound buffers
0 => int which;


//------------------------------------------------------------------------------
// SYNTHESIS!!
// this function is meant to be sporked so it can be stacked in time
//------------------------------------------------------------------------------
fun void synthesize( int uid )
{
    // get the buffer to use
    buffers[which] @=> SndBuf @ sound;
    // get the envelope to use
    envs[which] @=> ADSR @ envelope;
    // increment and wrap if needed
    which++; if( which >= buffers.size() ) 0 => which;

    // get a referencde to the audio fragment to synthesize
    inputFeaturesFile.windows[uid] @=> AudioWindow @ win;
    // get filename
    files[win.fileIndex] => string filename;
    // load into sound buffer
    filename => sound.read;
    // seek to the window start time
    ((win.windowTime::second)/samp) $ int => sound.pos;

    // print what we are about to play
    chout <= "synthsizing window: ";
    // print label
    chout <= win.uid <= "["
          <= win.fileIndex <= ":"
          <= win.windowTime <= ":POSITION="
          <= sound.pos() <= "]";
    // endline
    chout <= IO.newline();


    // open the envelope, overlap add this into the overall audio
    envelope.keyOn();
    // wait
    (EXTRACT_TIME*2)-envelope.releaseTime() => now;
    // start the release
    envelope.keyOff();
    // wait
    envelope.releaseTime() => now;

}


//------------------------------------------------------------------------------
// real-time similarity retrieval loop
//------------------------------------------------------------------------------
while( input.pos() < input.samples())
{
    // aggregate features over a period of time
    for( int frame; frame < NUM_FRAMES; frame++ )
    {
        //-------------------------------------------------------------
        // a single upchuck() will trigger analysis on everything
        // connected upstream from combo via the upchuck operator (=^)
        // the total number of output dimensions is the sum of
        // dimensions of all the connected unit analyzers
        //-------------------------------------------------------------
        combo.upchuck();  
        // get features
        for( int d; d < NUM_DIMENSIONS; d++) 
        {
            // store them in current frame
            combo.fval(d) => features[frame][d];
        }
        // advance time
        HOP => now;
    }
    
    // compute means for each coefficient across frames
    for( int d; d < NUM_DIMENSIONS; d++ )
    {
        // zero out
        0.0 => featureMean[d];
        // loop over frames
        for( int j; j < NUM_FRAMES; j++ )
        {
            // add
            features[j][d] +=> featureMean[d];
        }
        // average
        NUM_FRAMES /=> featureMean[d];
    }
    
    //-------------------------------------------------
    // search using KNN2; results filled in knnResults,
    // which should the indices of k nearest points
    //-------------------------------------------------
    knn.search( featureMean, K, knnResult );

        
    // SYNTHESIZE THIS
    for (int sound; sound < NUM_SOUNDS; sound++)
    {
        spork ~ synthesize( knnResult[Math.random2(0,knnResult.size()-1)] );
        100::ms => now;
    }
}
//------------------------------------------------------------------------------
// end of real-time similiarity retrieval loop
//------------------------------------------------------------------------------




//------------------------------------------------------------------------------
// function: load data file
//------------------------------------------------------------------------------
fun FileIO loadFile( string filepath )
{
    // reset
    0 => numPoints;
    0 => numCoeffs;
    
    // load data
    FileIO fio;
    if( !fio.open( filepath, FileIO.READ ) )
    {
        // error
        <<< "cannot open file:", filepath >>>;
        // close
        fio.close();
        // return
        return fio;
    }
    
    string str;
    string line;
    // read the first non-empty line
    while( fio.more() )
    {
        // read each line
        fio.readLine().trim() => str;
        // check if empty line
        if( str != "" )
        {
            numPoints++;
            str => line;
        }
    }
    
    // a string tokenizer
    StringTokenizer tokenizer;
    // set to last non-empty line
    tokenizer.set( line );
    // negative (to account for filePath windowTime)
    -2 => numCoeffs;
    // see how many, including label name
    while( tokenizer.more() )
    {
        tokenizer.next();
        numCoeffs++;
    }
    
    // see if we made it past the initial fields
    if( numCoeffs < 0 ) 0 => numCoeffs;
    
    // check
    if( numPoints == 0 || numCoeffs <= 0 )
    {
        <<< "no data in file:", filepath >>>;
        fio.close();
        return fio;
    }
    
    // print
    <<< "# of data points:", numPoints, "dimensions:", numCoeffs >>>;
    
    // done for now
    return fio;
}


//------------------------------------------------------------------------------
// function: read the data
//------------------------------------------------------------------------------
fun void readData( FileIO fio )
{
    // rewind the file reader
    fio.seek( 0 );
    
    // a line
    string line;
    // a string tokenizer
    StringTokenizer tokenizer;
    
    // points index
    0 => int index;
    // file index
    0 => int fileIndex;
    // file name
    string filename;
    // window start time
    float windowTime;
    // coefficient
    int c;
    
    // read the first non-empty line
    while( fio.more() )
    {
        // read each line
        fio.readLine().trim() => line;
        // check if empty line
        if( line != "" )
        {
            // set to last non-empty line
            tokenizer.set( line );
            // file name
            tokenizer.next() => filename;
            // window start time
            tokenizer.next() => Std.atof => windowTime;
            // have we seen this filename yet?
            if( filename2state[filename] == 0 )
            {
                // make a new string (<< appends by reference)
                filename => string sss;
                // append
                files << sss;
                // new id
                files.size() => filename2state[filename];
            }
            // get fileindex
            filename2state[filename]-1 => fileIndex;
            // set
            windows[index].set( index, fileIndex, windowTime );

            // zero out
            0 => c;
            // for each dimension in the data
            repeat( numCoeffs )
            {
                // read next coefficient
                tokenizer.next() => Std.atof => inFeatures[index][c];
                // increment
                c++;
            }
            
            // increment global index
            index++;
        }
    }
}

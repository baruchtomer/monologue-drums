
/* KORG Midi cc values
16, 17, 25: attack decay int
24, 26: lfo (rate, depth)
43: cutoff
44: resonance
39: level 1
40: level 2
28: drive
36,37: shape
*/
MIDIIn.connectAll; //first execute this;

k = MIDIOut.new(3); // depending on the port of the KORG
m=APCKey.new; // only then this;


(

~drums = (
	'cow': [ 56, 11, 0, 0, 100, 116, 14 ],
	'hhc': [ 115, 127, 0, 0, 115, 115, 70 ],
	'sn': [ 48, 38, 73, 88, 19, 127, 127 ],
	'hho': [ 106, 94, 120, 0, 4, 127, 70 ],
	'bd': [ 60, 20, 127, 0, 8, 112, 127 ] );

~lastNote=60;
~playDrum = {|drum|
	~stopDrum.value;
	k.control(2, 43, ~drums[drum][1]);
	k.control(2, 44, ~drums[drum][5]);
	k.control(2, 39, ~drums[drum][2]);
	k.control(2, 40, ~drums[drum][6]);
	k.control(2, 28, ~drums[drum][3]);
	k.control(2, 17, ~drums[drum][4]);
	k.noteOn(2, ~drums[drum][0], 127);
	~lastNote = ~drums[drum][0];
};
~stopDrum = {
	k.noteOff(2, ~lastNote);
};
~lightCounter = {|counter, state|
	if (state==\on) {
		if ((counter<8) && (m.currentScene==0)) {
			m.transport[counter].setColor(\redhi);
		} {
			if ((counter>=8) && (m.currentScene==1)) {
				m.transport[counter%8].setColor(\redhi);
			}
		}

	} {
		m.transport[counter % 8].setColor(\black);
	}
};
~playR= {
	r= {
		var counter=(-1);
		{
			var noteDur=~noteDur;
			counter = counter +1;
			if (counter>=~seq.size) {counter=0;};
//			if (counter>=8) {m.switchScene(1)};
			if (~seq[counter].notNil) {~playDrum.value(~seq[counter])};
			~lightCounter.value(counter, \on);
			(~bpm.bpm16th*noteDur).wait;
			~stopDrum.value;
			~lightCounter.value(counter, \off);
			(~bpm.bpm16th*(1-noteDur)).wait;
		}.loop;
	}.fork;
};
~seq=nil!16;
~bpm = 120;
~noteDur = 0.3;

2.do({|scene|
	m.switchScene(scene);
	8.do({|i|
		m.selectOne({|val|
			~seq[i+(scene*8)]=[\hho, \hhc, \cow, \sn, \bd][val]}, Array.fill(5, {|j| j*8+i}),
		{ ~seq[i+(scene*8)]=nil}, nil);
	});
});
m.switchScene(0);
m.transport[2].set({if (m.currentScene==1) {m.switchScene(0)}});
m.transport[3].set({if (m.currentScene==0) {m.switchScene(1)}});
m.transport[9].set({r.stop; ~playR.value}, {r.stop; ~stopDrum.value}, \toggle);
m.transport[10].set({r.stop});
m.selectOneSide({|i|
	var inst = [\hho, \hhc, \cow, \sn, \bd][i];
	7.do({|i| m.knobs[i].set({|val| ~drums[inst][i] = (val*127).asInt}) })}, (0..4), nil, nil
);
m.knobs[7].set({|val| ~noteDur = val.linlin(0,1, 0.1,1)});
)



(
~drums = (
	'hho': [ 106, 94, 120, 0, 4, 127, 60 ],
	'hhc': [ 115, 127, 0, 0, 115, 115, 60 ],
	'sn': [ 48, 38, 73, 88, 19, 127, 127 ],
	'bd': [ 60, 20, 127, 0, 8, 112,127 ],
  'cow': [ 56, 11, 22, 27, 95, 127,127 ]
)
)


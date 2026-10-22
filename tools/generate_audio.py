import wave, math, random, struct, pathlib
root=pathlib.Path(__file__).resolve().parents[1]/'assets/audio'
root.mkdir(parents=True,exist_ok=True)
sr=22050
random.seed(4732)
def write(name,seconds,fn,loop=False):
 with wave.open(str(root/(name+'.wav')),'wb') as f:
  f.setnchannels(1);f.setsampwidth(2);f.setframerate(sr)
  f.writeframes(b''.join(struct.pack('<h',int(max(-.98,min(.98,fn(i/sr)))*32767)) for i in range(int(seconds*sr))))
def note(t,freq,dur):
 if t<0 or t>=dur:return 0
 return (math.sin(t*freq*2*math.pi)+.25*math.sin(t*freq*4*math.pi))*.23*math.exp(-t*3.8)*min(t*60,1)
chords=[[261.626,329.628,391.995],[220,261.626,329.628],[174.614,220,261.626],[195.998,246.942,293.665]]
melody=[523.25,659.25,587.33,392,440,523.25,659.25,587.33,523.25,440,349.23,440,392,493.88,587.33,392]
def music(t):
 v=0
 for k in range(max(0,int(t//1.5)-3),int(t//1.5)+1):
  ch=chords[(k//4)%4];v+=note(t-k*1.5,ch[k%3],4)*.5
 for k in range(max(0,int(t//3)-2),int(t//3)+1):v+=note(t-k*3,melody[k%16],4.5)*.4
 return v*min(1,t/2,(48-t)/3)
write('meadow',48,music)
# Quiet original synthesized wind + sparse birds, intentionally no downloaded audio.
noise=[random.uniform(-1,1) for _ in range(sr*12)]
prev=0
for i,x in enumerate(noise):prev=prev*.985+x*.015;noise[i]=prev
write('breeze',12,lambda t:noise[min(len(noise)-1,int(t*sr))]*.42+(.018*math.sin(2*math.pi*(1800*t+80*math.sin(t*12)))*max(0,math.sin(t*.8))**30))
for name,tones in {'pick':[660,880,1100],'sale':[523,659,784,1047],'quest':[392,523,659,784,1047],'save':[440,660],'bite':[740,740,980],'step':[180,200]}.items():
 dur=len(tones)*.11+.5
 write(name,dur,lambda t,tones=tones:sum(note(t-j*.11,hz,.6)*.65 for j,hz in enumerate(tones)))

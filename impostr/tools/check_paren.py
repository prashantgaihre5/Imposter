from pathlib import Path
p=Path(r'c:\Users\livel\OneDrive\Desktop\IMPOSTER\impostr\lib\screens\home_screen.dart')
s=p.read_text().splitlines()
count=0
for i,line in enumerate(s, start=1):
    for j,ch in enumerate(line, start=1):
        if ch=='(':
            count+=1
        elif ch==')':
            count-=1
        if count<0:
            print(f'Negative at line {i} col {j}')
            count=0
print('final_count=',count)
# print counts per line
count=0
for i,line in enumerate(s, start=1):
    for ch in line:
        if ch=='(':
            count+=1
        elif ch==')':
            count-=1
    if i%20==0 or i>140:
        print(f'line {i} -> cumulative {count} : {line[:80]}')

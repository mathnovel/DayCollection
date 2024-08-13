G=tf(1,[1 2 1]);
PI=tf(1.2*[1 1],[1 0]);
clf reset
step(feedback(G*PI,1));

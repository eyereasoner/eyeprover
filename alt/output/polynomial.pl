:- op(1200, xfx, :+).

answer('urn:example:roots'([[1,0],[-10,0],[35,0],[-50,0],[24,0]],[[4.00000000745058,0.0],[2.99999999254942,0.0],[1.99999999254942,0.0],[1.00000000745058,0.0]])).
answer('urn:example:roots'([[1,0],[-9,-5],[14,33],[24,-44],[-26,0]],[[3.0,2.0],[5.00000000000001,0.999999999999993],[-5.773159728050814e-15,1.0],[0.999999999999996,1.0]])).

step((true:+'urn:example:roots'([[1,0],[-10,0],[35,0],[-50,0],[24,0]],A)),'urn:example:roots'([[1,0],[-10,0],[35,0],[-50,0],[24,0]],[[4.00000000745058,0.0],[2.99999999254942,0.0],[1.99999999254942,0.0],[1.00000000745058,0.0]]),true).
step((true:+'urn:example:roots'([[1,0],[-9,-5],[14,33],[24,-44],[-26,0]],A)),'urn:example:roots'([[1,0],[-9,-5],[14,33],[24,-44],[-26,0]],[[3.0,2.0],[5.00000000000001,0.999999999999993],[-5.773159728050814e-15,1.0],[0.999999999999996,1.0]]),true).

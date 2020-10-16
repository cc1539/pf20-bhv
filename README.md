# Black Hole Visualizer

Simulates the bending of light around a black hole. Partially inspired by the images of the M87 supermassive black hole taken in April of 2019.


To change the parameters of the visualization, you hold down the left mouse button anywhere inside the window, where the very leftmost coordinate results in the smallest value and rightmost coordinate in the largest, while also holding down a key corresponding to the property you want to change.\
b - accretion disk brightness\
c - accretion disk radius\
g - black hole radius\
r - black hole spin\
j - ray jitter


Here we use a technique called sphere tracing, which is unreasonably convenient when it comes to rendering a convincing black hole. The sphere tracing technique is an extension of the ray marching technique, in which the ray shot out of every pixel on the screen into the scene moves by an amount proportional to its distance (as opposed to a fixed distance as is the case with ray marching) to the closest object -- in this case, the black hole. Since the strength of gravity increases as we get closer to the black hole, it makes sense that light rays will curve more, and so we require more updates per distance marched; sphere tracing does this naturally since the close proximity to the black hole means we only move a little bit per step. On the other hand, when the ray is far from the black hole, there is less gravity, so light will tend to move in significantly straighter lines, and so fewer updates per distance are needed; once again, sphere tracing naturally does this.


The trickiest part is probably the accretion disk, which I opted to generate procedurally instead of by simply using a texture. I also wanted the disk to have some thickness to it, instead of it being perfectly flat. To render the disk, whenever the ray intersected the disk, I would have it ray march normally through it and volumetrically accumulate color data.


Finally, to make it look a little better, I applied a post-processing bloom.

from manim import *

class CurvedSurfaceExample(ThreeDScene):
    def construct(self):
        # Set up the scene
        self.set_camera_orientation(phi=75 * DEGREES, theta=-30 * DEGREES)

        # Create a parametric surface
        def param_surface(u, v):
            x = u
            y = v
            z = np.sin(u) * np.cos(v)
            return np.array([x, y, z])

        surface = ParametricSurface(
            param_surface,
            u_range=[-3, 3],
            v_range=[-3, 3],
            resolution=(30, 30),
            checkerboard_colors=[BLUE_D, BLUE_E],
            stroke_width=0.5,
        )

        # Add the surface to the scene
        self.add(surface)

        # Animate the camera
        self.begin_ambient_camera_rotation(rate=0.1)
        self.wait(10)
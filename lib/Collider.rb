require 'mathn'

module Collider
    
    ELLIPTIC = 1
    RECTANGLE = 2 # Not yet implemented
    
    def self.test_collision(entity_1, entity_2)
        if entity_1.box == ELLIPTIC && entity_2.box == ELLIPTIC then
            self.elliptic(entity_1.xsize, entity_1.ysize, entity_2.xsize, entity_2.ysize, entity_1.x-entity_2.x, entity_1.y-entity_1.ysize-entity_2.y+entity_2.ysize)
        end
    end
    
    def self.circle_square(radius, circle_x, circle_y, size, square_x, square_y)
        dx = circle_x - square_x
        dy = circle_y - square_y
        
        if (dx > size + radius) || (dy > size + radius) then
            return false
        end
        if (dx <= size) || (dy <= size) then
            return true
        end
        
        cd = (dx - size)**2 + (dy - size)**2
        return (cd <= radius**2)
    end
    
    def self.elliptic(first_a, first_b, second_a, second_b, xdiff, ydiff) # Highly dangerous!!!
        a_ = first_a
        b_ = first_b
        c_ = second_a
        d_ = second_b
        dx_ = xdiff
        dy_ = ydiff
        
        a = a_*a_
        b = b_*b_
        c = c_*c_
        d = d_*d_
        dx = dx_*dx_
        dy = dy_*dy_
        
        return false if [dx,dy].max > 2*(a+c) # Exclude impossible collisions
        
        coeff_0 = 1.0/(c*d)
        coeff_1 = (-a*b-b*c-a*d+b*dx+a*dy)/(a*b*c*d)
        coeff_2 = (b*c+a*d+c*d-d*dx-c*dy)/(a*b*c*d)
        coeff_3 = -1.0/(a*b)
        
        points = Polythree.solve(coeff_3, coeff_2, coeff_1, coeff_0)
        ret = points.count {|p| !(p.imag.abs > 0.0001) && p.real < 0.0}
        
        return (ret <= 1)
    end
    
end

module Polythree
    
    SQRT_THREE = Math::sqrt(3)
    UNIT_ROOTS = [Complex(1,0), Complex(-1/2, SQRT_THREE/2), Complex(-1/2, -SQRT_THREE/2)]
    
    def self.solve(a, b, c, d)
        discr_0 = b*b - 3*a*c
        discr_1 = 2*b*b*b - 9*a*b*c + 27*a*a*d
        c = Math::cbrt((discr_1 + Math::sqrt(discr_1*discr_1 - 4*discr_0*discr_0*discr_0))/2)
        ret = []
        0.upto(2) do |i|
            ret[i] = -(b + UNIT_ROOTS[i]*c + discr_0/(UNIT_ROOTS[i]*c))/(3*a)
        end
        return ret
    end
    
end

# Source of elliptical collision algorithm: http://www.csis.hku.hk/research/techreps/document/TR-2005-03.pdf

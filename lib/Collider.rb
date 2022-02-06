module Collider

    ELLIPTIC = 1

	def self.test_collision(entity_1, entity_2)
        if entity_1.box == ELLIPTIC && entity_2.box == ELLIPTIC then
            self.elliptic(entity_1.xsize, entity_1.ysize, entity_2.xsize, entity_2.ysize, entity_1.x-entity_2.x, entity_1.y-entity_1.ysize-entity_2.y+entity_2.ysize)
        end
    end

    def self.elliptic(a1, b1, a2, b2, dx, dy)
        # Helper terms.

		a1_squared = a1 * a1
		b1_squared = b1 * b1
		a2_squared = a2 * a2
		b2_squared = b2 * b2
		
		dx_squared = dx * dx
		dy_squared = dy * dy

		# Test if the circles spanned by the bigger semiaxes collide.

		return false if [dx_squared, dy_squared].max > 2.0 * [(a1_squared + a2_squared), (b1_squared + b2_squared)].max

		# Construct the characteristic polynomial f(x) for both ellipse matrices.
		# If and only if f(x) has less than two negative real roots, the ellipses collide.

		coeff_0 = a1_squared * b1_squared
		coeff_1 = (-a1_squared * b1_squared - b1_squared * a2_squared - a1_squared * b2_squared + b1_squared * dx_squared + a1_squared * dy_squared)
		coeff_2 = (b1_squared * a2_squared + a1_squared * b2_squared + a2_squared * b2_squared - b2_squared * dx_squared - a2_squared * dy_squared)
		coeff_3 = -a2_squared * b2_squared

		# Determine the values of f(x) at negative infinity and at zero.

		lower_limit = (coeff_3.abs > 0.0 ? -coeff_3 : (coeff_2.abs > 0.0 ? coeff_2 : (coeff_1.abs > 0.0 ? -coeff_1 : coeff_0)))
		value_at_zero = coeff_0

		# Calculate the derivative f'(x) of f(x) to help determine root positions,
		# since calculating roots of a third-order polynomial is quite slow.

		deriv_0 = coeff_1
		deriv_1 = 2.0 * coeff_2
		deriv_2 = 3.0 * coeff_3

		discriminant_of_derivative = deriv_1 * deriv_1 - 4 * deriv_2 * deriv_0

		return true if discriminant_of_derivative <= 0.0

		# Find out the extrema of f(x) by using the pq formula to solve f'(x)=0.

		denominator_term = 1.0 / (2.0 * deriv_2)

		base_term = -deriv_1 * denominator_term
		sqrt_term = Math.sqrt(discriminant_of_derivative) * denominator_term.abs

		lower_extremum = base_term - sqrt_term
		upper_extremum = base_term + sqrt_term

		# If the lower extremum is higher than zero, we have less than two roots.

		return true if lower_extremum >= 0.0

		# Finally, just count the roots by counting any sign changes.

		lower_extremum_square = lower_extremum * lower_extremum
		lower_extremum_cubic = lower_extremum_square * lower_extremum

		lower_extremum_value = coeff_0 + coeff_1 * lower_extremum + coeff_2 * lower_extremum_square + coeff_3 * lower_extremum_cubic

		upper_extremum_square = upper_extremum * upper_extremum
		upper_extremum_cubic = upper_extremum_square * upper_extremum

		upper_extremum_value = coeff_0 + coeff_1 * upper_extremum + coeff_2 * upper_extremum_square + coeff_3 * upper_extremum_cubic

		return (lower_limit * lower_extremum_value >= 0.0 && value_at_zero * upper_extremum_value >= 0.0)
    end

end
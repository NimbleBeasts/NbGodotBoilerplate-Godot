# MIT License
# 
# Copyright (c) 2021 Julien Vanelian
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# Based on the work of JulienVanelian; Modified by NimbleBeasts
# https://github.com/JulienVanelian/godot-rand-utils

class_name Core_RandomNumberGenerator extends RandomNumberGenerator

# Partial implementation of python's string constants: https://docs.python.org/3/library/string.html
const ASCII_LETTERS = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
const ASCII_LOWERCASE = "abcdefghijklmnopqrstuvwxyz"
const ASCII_UPPERCASE = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
const ASCII_DIGITS = "0123456789"
const ASCII_HEXDIGITS = "0123456789ABCDEF"
const ASCII_PUNCTUATION =  "!\"#$%&'()*+, -./:;<=>?@[\\]^_`{|}~"

var _rng: RandomNumberGenerator

## Constructor
func _init():
	_rng = RandomNumberGenerator.new()

## Returns a boolean based on a probability
func bool(probability: float = .5) -> bool:
	return bool(_rng.randf() < 1 - probability)

## Returns a normalized Vector2
func vec2() -> Vector2:
	return Vector2(_rng.randf(), _rng.randf())

## Returns a normalized Vector3
func vec3() -> Vector3:
	return Vector3(_rng.randf(), _rng.randf(), _rng.randf())

## Returns a random string containing letters with a given length
func letters(length: int = 1, unique: bool = false) -> String:
	return from_string(ASCII_LETTERS, length, unique)

## Returns a random string containing numeric characters with a given length
func numeric(length: int = 1, unique: bool = false) -> String:
	return from_string(ASCII_DIGITS, length, unique)

## Returns a random string containing hex characters with a given length
func hex(length: int = 1, uppercase: bool = false, unique: bool = false) -> String:
	return from_string(ASCII_HEXDIGITS.to_upper() if uppercase else ASCII_HEXDIGITS, length, unique)

## Returns a random string containing alphanumeric characters with a given length
func alphanumeric(length: int = 1, unique: bool = false) -> String:
	return from_string(ASCII_LETTERS + ASCII_DIGITS, length, unique)

## Returns a random string containing alphanumeric characters with a given length. Letters are lowercase
func alphanumeric_simple(length: int = 1, unique: bool = false) -> String:
	return from_string(ASCII_LOWERCASE + ASCII_DIGITS, length, unique)

## Returns a random string containing ASCII characters with a given length.
func string(length: int = 1, unique: bool = false) -> String:
	return from_string(ASCII_LETTERS + ASCII_DIGITS + ASCII_PUNCTUATION, length, unique)

## Returns a random string from a given length and string characters
func from_string(text, length: int = 1, unique: bool = false) -> String:
	var array: PackedByteArray = from_array(text.to_utf8(), length, unique)
	return array.get_string_from_utf8()

## Returns a Color instance with randomized properties
func color(
	hueMin: float = 0.0,
	hueMax: float = 1.0,
	saturationMin: float = 0.0,
	saturationMax: float = 1.0,
	valueMin: float = 0.0,
	valueMax: float = 1.0,
	alphaMin: float = 1.0,
	alphaMax: float = 1.0
	) -> Color:
	var opaque = alphaMin == alphaMax

	return Color.from_hsv(
		_rng.randf_range(hueMin, hueMax),
		_rng.randf_range(saturationMin, saturationMax),
		_rng.randf_range(valueMin, valueMax),
		1.0 if opaque else _rng.randf_range(alphaMin, alphaMax))

## Returns a random byte (int)
func byte() -> int:
	return _rng.randi() % 256

## Returns a PoolByteArray filled with n random bytes
func byte_array(size: int = 1) -> PackedByteArray: 
	var array = []

	for _i in range(0, size):
		array.append(byte())

	return PackedByteArray(array)

## Returns one or multiple random elements from an array
func from_array(array: Array, num: int = 1, unique: bool = false) -> Array:
	assert(num >= 1, "RandUtils ERROR: Invalid element count.")

	if unique:
		assert(num <= len(array), "RandUtils ERROR: Ran out of characters.")

	if len(array) == 1:
		return array[0]
	elif num == 1:
		return [array[_rng.randi() % len(array)]]
	else:
		var results = []

		while num > 0:
			var index = _rng.randi() % len(array)
			results.append(array[index])
			num -= 1

			if unique:
				array.erase(index)

		return results

Strict

Import mojo
Class Sprite
	Field image:Image
	Field pixels:Int[]
	Field createImages:Bool
	Field x:Float, y:Float
	Field collisionRect:Rect
	
	Method New(ruta:String)
		image = LoadImage(ruta)
		pixels = New Int[image.Width() * image.Height()]
		createImages = True
	End
	
	Method Draw:Void(px:Float, py:Float)
		CreateImages()
		x = px
		y = py
		DrawImage(image, x, y)
		If collisionRect <> Null Then
			SetColor(255, 0, 255)
			SetColor(255, 255, 255)
		End
	End
	
	Method CreateImages:Void()
		If Not createImages Return
		createImages = False
		Cls(0, 0, 0)
		DrawImage(image, 0, 0)
		ReadPixels(pixels, 0, 0, image.Width(), image.Height())
		
		' convert the mask colour (black) to alpha
		For Local i:Int = 0 Until image.Width() * image.Height()
			Local argb:Int = pixels[i]
			Local a:Int = (argb Shr 24) & $ff
			Local r:Int = (argb Shr 16) & $ff
			Local g:Int = (argb Shr 8) & $ff
			Local b:Int = argb & $ff

			If a = 255 And r = 0 And g = 0 And b = 0 Then
				a = 0
				argb = (a Shl 24) | (r Shl 16) | (g Shl 8) | b
				pixels[i] = argb
			End
		Next

		image.SetHandle(image.Width() / 2, image.Height() / 2)

		SetColor(255, 255, 255)
		Cls(0, 0, 0)
	End
	
	Method Collide:Bool(sprite:Sprite)
		Local rect1:Rect = New Rect
		
		rect1.x = x - image.HandleX()
		rect1.y = y - image.HandleY()
		rect1.width = image.Width()
		rect1.height = image.Height()
		
		Local rect2:Rect = New Rect

		rect2.x = sprite.x - sprite.image.HandleX()
		rect2.y = sprite.y - sprite.image.HandleY()
		rect2.width = sprite.image.Width()
		rect2.height = sprite.image.Height()
		
		If rect1.IntersectWith(rect2)
			collisionRect = rect1.Intersection(rect2)
			If collisionRect <> Null Then
				For Local iy:Int = collisionRect.y Until collisionRect.height + collisionRect.y
					For Local ix:Int = collisionRect.x Until collisionRect.width + collisionRect.x
						Local a1:Int = (GetPixel(ix - rect1.x, iy - rect1.y) Shr 24) & $ff
						Local a2:Int = (sprite.GetPixel(ix - rect2.x, iy - rect2.y) Shr 24) & $ff
						If a1 > 0 And a2 > 0
							Return True
						End
					Next
				Next
			End
		Else
			collisionRect = Null
		End
		Return False
	End
	
	Method GetPixel:Int(x:Int, y:Int)
		Return pixels[x + y * image.Width()]
	End
End

Class Rect
	Field x:Int
	Field y:Int
	Field width:Int
	Field height:Int
	
	Method New(x:Int, y:Int, width:Int, height:Int)
		Self.x = x
		Self.y = y
		Self.width = width
		Self.height = height
	End
	
	Method IntersectWith:Bool(r:Rect)
		Local tw:Int = Self.width
		Local th:Int = Self.height
		Local rw:Int = r.width
		Local rh:Int = r.height
		If (rw <= 0 Or rh <= 0 Or tw <= 0 Or th <= 0)
			Return False
		End
		Local tx:Int = Self.x
		Local ty:Int = Self.y
		Local rx:Int = r.x
		Local ry:Int = r.y
		rw += rx
		rh += ry
		tw += tx
		th += ty

		Return ((rw < rx Or rw > tx) And
				(rh < ry Or rh > ty) And
				(tw < tx Or tw > rx) And
				(th < ty Or th > ry))
	End
	
	Method Intersection:Rect(r:Rect)
		Local tx1:Int = Self.x
		Local ty1:Int = Self.y
		Local rx1:Int = r.x
		Local ry1:Int = r.y
		
		Local tx2:Float = tx1
		Local ty2:Float = ty1
		Local rx2:Float = rx1
		Local ry2:Float = ry1
		
		tx2 += Self.width
		ty2 += Self.height
		rx2 += r.width
		ry2 += r.height
		
		If (tx1 < rx1) Then tx1 = rx1
		If (ty1 < ry1) Then ty1 = ry1
		If (tx2 > rx2) Then tx2 = rx2
		If (ty2 > ry2) Then ty2 = ry2
		tx2 -= tx1
		ty2 -= ty1

		If (tx2 < -2147483648) tx2 = -2147483648
		If (ty2 < -2147483648) ty2 = -2147483648
		Return New Rect(tx1, ty1, Int(tx2), Int(ty2))
	End
	
	Method ToString:String()
		Return x + "," + y + "," + width + "," + height
	End
	
End
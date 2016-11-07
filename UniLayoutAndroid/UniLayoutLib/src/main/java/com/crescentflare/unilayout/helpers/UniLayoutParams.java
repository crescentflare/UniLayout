package com.crescentflare.unilayout.helpers;

import android.content.Context;
import android.content.res.TypedArray;
import android.graphics.Point;
import android.util.AttributeSet;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;

import com.crescentflare.unilayout.R;

/**
 * UniLayout helper: layout parameters
 * A custom layout parameter class to be used within the layout containers of the library
 */
public class UniLayoutParams extends ViewGroup.MarginLayoutParams
{
    // ---
    // Gravity flags
    // ---

    private static final int GRAVITY_FLAG_CENTER_HORIZONTAL = 0x1;
    private static final int GRAVITY_FLAG_RIGHT = 0x2;
    private static final int GRAVITY_FLAG_CENTER_VERTICAL = 0x4;
    private static final int GRAVITY_FLAG_BOTTOM = 0x8;
    private static final int GRAVITY_FLAG_HORIZONTAL_MASK = 0x3;
    private static final int GRAVITY_FLAG_VERTICAL_MASK = 0xC;


    // ---
    // Members
    // ---

    public int minWidth = 0;
    public int maxWidth = 0xFFFFFF;
    public int minHeight = 0;
    public int maxHeight = 0xFFFFFF;
    public float horizontalGravity = 0;
    public float verticalGravity = 0;
    public float weight = 0;


    // ---
    // Initialization
    // ---

    public UniLayoutParams(int width, int height)
    {
        super(width, height);
    }

    public UniLayoutParams(Context c, AttributeSet attrs)
    {
        // Default attributes with margin support
        super(c, attrs);

        // Read other properties
        int gravity = 0;
        TypedArray a = c.obtainStyledAttributes(attrs, R.styleable.UniLayoutParams);
        weight = a.getInt(R.styleable.UniLayoutParams_uni_weight, 0);
        minWidth = a.getDimensionPixelSize(R.styleable.UniLayoutParams_uni_min_width, 0);
        maxWidth = a.getDimensionPixelSize(R.styleable.UniLayoutParams_uni_max_width, 0xFFFFFF);
        minHeight = a.getDimensionPixelSize(R.styleable.UniLayoutParams_uni_min_height, 0);
        maxHeight = a.getDimensionPixelSize(R.styleable.UniLayoutParams_uni_max_height, 0xFFFFFF);
        gravity = a.getInt(R.styleable.UniLayoutParams_uni_gravity, 0);
        if ((gravity & GRAVITY_FLAG_HORIZONTAL_MASK) == GRAVITY_FLAG_RIGHT)
        {
            horizontalGravity = 1;
        }
        else if ((gravity & GRAVITY_FLAG_HORIZONTAL_MASK) == GRAVITY_FLAG_CENTER_HORIZONTAL)
        {
            horizontalGravity = 0.5f;
        }
        else
        {
            horizontalGravity = a.getFloat(R.styleable.UniLayoutParams_uni_horizontal_gravity, 0);
        }
        if ((gravity & GRAVITY_FLAG_VERTICAL_MASK) == GRAVITY_FLAG_BOTTOM)
        {
            verticalGravity = 1;
        }
        else if ((gravity & GRAVITY_FLAG_VERTICAL_MASK) == GRAVITY_FLAG_CENTER_VERTICAL)
        {
            verticalGravity = 0.5f;
        }
        else
        {
            verticalGravity = a.getFloat(R.styleable.UniLayoutParams_uni_vertical_gravity, 0);
        }
        a.recycle();
    }
}

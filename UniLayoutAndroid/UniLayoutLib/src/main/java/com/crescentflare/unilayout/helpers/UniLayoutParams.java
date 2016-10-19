package com.crescentflare.unilayout.helpers;

import android.graphics.Point;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;

/**
 * UniLayout helper: layout parameters
 * A custom layout parameter class to be used within the layout containers of the library
 */
public class UniLayoutParams extends ViewGroup.MarginLayoutParams
{
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
}

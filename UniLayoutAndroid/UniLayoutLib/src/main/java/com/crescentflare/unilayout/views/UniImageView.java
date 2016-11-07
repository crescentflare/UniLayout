package com.crescentflare.unilayout.views;

import android.content.Context;
import android.util.AttributeSet;
import android.widget.ImageView;

/**
 * UniLayout view: a simple image
 * Extends ImageView, currently it's just an alias to have the same name as the iOS class
 */
public class UniImageView extends ImageView
{
    // ---
    // Initialization
    // ---

    public UniImageView(Context context)
    {
        this(context, (AttributeSet)null);
    }

    public UniImageView(Context context, AttributeSet attrs)
    {
        super(context, attrs);
        init(attrs);
    }

    public UniImageView(Context context, AttributeSet attrs, int defStyleAttr)
    {
        this(context, attrs);
    }

    public UniImageView(Context context, AttributeSet attrs, int defStyleAttr, int defStyleRes)
    {
        this(context, attrs);
    }

    private void init(AttributeSet attrs)
    {
    }
}

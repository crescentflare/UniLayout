package com.crescentflare.unilayout.views;

import android.content.Context;
import android.util.AttributeSet;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.ImageView;

import com.crescentflare.unilayout.helpers.UniLayoutParams;

/**
 * UniLayout view: a simple image
 * Extends ImageView to use UniLayoutParams and provide some minor layout improvements
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

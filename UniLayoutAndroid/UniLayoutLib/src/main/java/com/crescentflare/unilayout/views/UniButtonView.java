package com.crescentflare.unilayout.views;

import android.content.Context;
import android.util.AttributeSet;
import android.widget.Button;

/**
 * UniLayout view: a simple button
 * Extends Button, currently it's just an alias to have the same name as the iOS class
 */
public class UniButtonView extends Button
{
    // ---
    // Initialization
    // ---

    public UniButtonView(Context context)
    {
        this(context, (AttributeSet)null);
    }

    public UniButtonView(Context context, AttributeSet attrs)
    {
        super(context, attrs);
        init(attrs);
    }

    public UniButtonView(Context context, AttributeSet attrs, int defStyleAttr)
    {
        this(context, attrs);
    }

    public UniButtonView(Context context, AttributeSet attrs, int defStyleAttr, int defStyleRes)
    {
        this(context, attrs);
    }

    private void init(AttributeSet attrs)
    {
    }


    // ---
    // Override layout to force re-measure (to get text alignment to work properly)
    // ---

    @Override
    public void layout(int left, int top, int right, int bottom)
    {
        measure(MeasureSpec.makeMeasureSpec(right - left, MeasureSpec.EXACTLY), MeasureSpec.makeMeasureSpec(bottom - top, MeasureSpec.EXACTLY));
        super.layout(left, top, right, bottom);
    }
}

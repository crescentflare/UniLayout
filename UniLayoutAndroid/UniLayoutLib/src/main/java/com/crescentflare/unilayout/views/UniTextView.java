package com.crescentflare.unilayout.views;

import android.content.Context;
import android.util.AttributeSet;
import android.view.ViewGroup;
import android.widget.TextView;

import com.crescentflare.unilayout.helpers.UniLayoutParams;

/**
 * UniLayout view: a view with simple text
 * Extends TextView, includes a workaround to get text alignment to work with minimum width
 */
public class UniTextView extends TextView
{
    // ---
    // Initialization
    // ---

    public UniTextView(Context context)
    {
        this(context, (AttributeSet)null);
    }

    public UniTextView(Context context, AttributeSet attrs)
    {
        super(context, attrs);
        init(attrs);
    }

    public UniTextView(Context context, AttributeSet attrs, int defStyleAttr)
    {
        this(context, attrs);
    }

    public UniTextView(Context context, AttributeSet attrs, int defStyleAttr, int defStyleRes)
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

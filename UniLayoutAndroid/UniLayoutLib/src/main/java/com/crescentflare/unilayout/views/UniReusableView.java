package com.crescentflare.unilayout.views;

import android.content.Context;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.Drawable;
import android.graphics.drawable.StateListDrawable;
import android.os.Build;
import android.util.AttributeSet;
import android.view.View;

import com.crescentflare.unilayout.containers.UniFrameContainer;
import com.crescentflare.unilayout.helpers.UniLayoutParams;

/**
 * UniLayout view: a reusable view container
 * Provides a container with a customizable view and divider to be used in the UniReusingContainer
 */
public class UniReusableView extends UniFrameContainer
{
    // ---
    // Members
    // ---

    private View itemView;
    private View dividerView;
    private int backgroundColor = 0xffffffff;
    private int highlightColor;


    // ---
    // Initialization
    // ---

    public UniReusableView(Context context)
    {
        this(context, (AttributeSet)null);
    }

    public UniReusableView(Context context, AttributeSet attrs)
    {
        super(context, attrs);
        init(attrs);
    }

    public UniReusableView(Context context, AttributeSet attrs, int defStyleAttr)
    {
        this(context, attrs);
    }

    public UniReusableView(Context context, AttributeSet attrs, int defStyleAttr, int defStyleRes)
    {
        this(context, attrs);
    }

    private void init(AttributeSet attrs)
    {
        UniLayoutParams layoutParams = new UniLayoutParams(LayoutParams.MATCH_PARENT, 1);
        dividerView = new View(getContext());
        dividerView.setBackgroundColor(0xffc0c0c0);
        layoutParams.verticalGravity = 1;
        dividerView.setLayoutParams(layoutParams);
        addView(dividerView);
        setHighlightColor(0xffc0c0c0);
    }


    // ---
    // Access values
    // ---

    public View getDividerView()
    {
        return dividerView;
    }

    public View getItemView()
    {
        return itemView;
    }

    public void setItemView(View itemView)
    {
        if (itemView == this.itemView)
        {
            return;
        }
        if (this.itemView != null)
        {
            removeView(this.itemView);
        }
        this.itemView = itemView;
        if (itemView != null)
        {
            itemView.setLayoutParams(new UniLayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.WRAP_CONTENT));
            addView(itemView, 0);
            itemView.setSelected(isSelected());
            itemView.setEnabled(isEnabled());
        }
    }

    public void setBackgroundColor(int color)
    {
        backgroundColor = color;
        updateBackground();
    }

    public void setHighlightColor(int color)
    {
        highlightColor = color;
        updateBackground();
    }


    // ---
    // Set state
    // ---

    @Override
    public void setSelected(boolean selected)
    {
        setSelected(selected, false);
    }

    public void setSelected(boolean selected, boolean animated)
    {
        if (itemView != null)
        {
            boolean changedSelection = selected != itemView.isSelected();
            if (changedSelection)
            {
                if (itemView instanceof AnimatingItemView)
                {
                    ((AnimatingItemView)itemView).setSelected(selected, animated);
                }
                else
                {
                    itemView.setSelected(selected);
                }
            }
        }
        super.setSelected(selected);
    }

    @Override
    public void setEnabled(boolean enabled)
    {
        setSelected(enabled, false);
    }

    public void setEnabled(boolean enabled, boolean animated)
    {
        super.setEnabled(enabled);
        if (itemView != null)
        {
            if (itemView instanceof AnimatingItemView)
            {
                ((AnimatingItemView)itemView).setEnabled(enabled, animated);
            }
            else
            {
                itemView.setEnabled(enabled);
            }
        }
    }


    // ---
    // Helpers
    // ---

    private void updateBackground()
    {
        Drawable setDrawable;
        if (highlightColor != 0)
        {
            StateListDrawable drawable = new StateListDrawable();
            ColorDrawable selectedColorDrawable = new ColorDrawable(blendColor(backgroundColor, highlightColor));
            drawable.addState(new int[]{android.R.attr.state_selected}, selectedColorDrawable);
            drawable.addState(new int[]{android.R.attr.state_focused}, selectedColorDrawable);
            drawable.addState(new int[]{android.R.attr.state_pressed}, selectedColorDrawable);
            drawable.addState(new int[0], new ColorDrawable(backgroundColor));
            setDrawable = drawable;
        }
        else
        {
            setDrawable = new ColorDrawable(backgroundColor);
        }
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.JELLY_BEAN)
        {
            setBackgroundDrawable(setDrawable);
        }
        else
        {
            setBackground(setDrawable);
        }
    }

    private int blendColor(int first, int second)
    {
        int firstR = (first >> 16) & 0xFF;
        int firstG = (first >> 8) & 0xFF;
        int firstB = first & 0xFF;
        int secondA = (second >> 24) & 0xFF;
        int secondR = (second >> 16) & 0xFF;
        int secondG = (second >> 8) & 0xFF;
        int secondB = second & 0xFF;
        int resultR = firstR * (255 - secondA) / 255 + secondR * secondA / 255;
        int resultG = firstG * (255 - secondA) / 255 + secondG * secondA / 255;
        int resultB = firstB * (255 - secondA) / 255 + secondB * secondA / 255;
        return (first & 0xFF000000) + (resultR << 16) + (resultG << 8) + resultB;
    }


    // ---
    // Interface for a item view with optional animation
    // ---

    public interface AnimatingItemView
    {
        void setSelected(boolean selected, boolean animated);
        void setEnabled(boolean enabled, boolean animated);
    }
}
